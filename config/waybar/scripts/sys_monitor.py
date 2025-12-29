#!/usr/bin/env python3
import json
import psutil
import subprocess
import re
import os
import platform
import glob

# ---------------------------------------------------
# CONFIGURATION & ICONS
# ---------------------------------------------------
CPU_ICON = ""
GPU_ICON = "GPU"
MEM_ICON = ""
SSD_ICON = ""
HDD_ICON = "󰋊"

# Catppuccin / Pastel Colors
PINK = "#f5c2e7"
COLOR_LOW = "#a6e3a1"      # Green
COLOR_MID_LOW = "#89dceb"  # Blue/Cyan
COLOR_MID = "#f9e2af"      # Yellow
COLOR_MID_HIGH = "#fab387" # Orange
COLOR_HIGH = "#f38ba8"     # Red
COLOR_CRIT = "#ff0000"     # Bright Red

def get_color(value, is_temp=False):
    """Returns a hex color code based on value intensity."""
    if value is None: return "#ffffff"
    try:
        val = float(value)
    except:
        return "#ffffff"
    
    # Scale adjustment: Temps usually go to 90, Usage to 100
    if is_temp:
        if val < 45: return COLOR_LOW
        if val < 60: return COLOR_MID_LOW
        if val < 75: return COLOR_MID
        if val < 85: return COLOR_MID_HIGH
        return COLOR_HIGH
    else:
        if val < 30: return COLOR_LOW
        if val < 50: return COLOR_MID_LOW
        if val < 70: return COLOR_MID
        if val < 85: return COLOR_MID_HIGH
        return COLOR_HIGH

# ---------------------------------------------------
# DATA COLLECTION
# ---------------------------------------------------

def get_cpu_info():
    """Fetches CPU Name, Usage, Freq, and Temp."""
    # 1. Name
    cpu_name = "Unknown CPU"
    try:
        if platform.system() == "Linux":
            with open("/proc/cpuinfo", "r") as f:
                for line in f:
                    if "model name" in line:
                        cpu_name = line.split(":")[1].strip()
                        # Clean up name for display
                        cpu_name = cpu_name.replace("(R)", "").replace("(TM)", "").split("@")[0].strip()
                        break
    except: pass

    # 2. Stats
    usage = psutil.cpu_percent(interval=0.1)
    
    # 3. Frequency
    freq_curr = 0
    freq_max = 0
    try:
        freq = psutil.cpu_freq()
        if freq:
            freq_curr = freq.current
            freq_max = freq.max
    except: pass

    # 4. Temp (Best effort for Linux)
    temp = 0
    try:
        temps = psutil.sensors_temperatures()
        # Common labels for CPU temp packages
        for key in ['k10temp', 'coretemp', 'zenpower', 'asus']:
            if key in temps:
                # usually Tctl or Package id 0 is the main one
                temp = temps[key][0].current
                break
    except: pass

    return {
        "name": cpu_name,
        "usage": usage,
        "freq_c": freq_curr,
        "freq_m": freq_max,
        "temp": temp
    }

def get_nvidia_info():
    """Fetches Nvidia GPU info via nvidia-smi."""
    try:
        # Get Name
        name_out = subprocess.check_output(["nvidia-smi", "--query-gpu=name", "--format=csv,noheader,nounits"], text=True)
        gpu_name = name_out.strip()

        # Get Stats
        stats_out = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu,power.draw,clocks.gr,clocks.max.sm", "--format=csv,noheader,nounits"],
            text=True
        )
        match = re.search(r"(\d+)\s*,\s*(\d+)\s*,\s*([\d\.]+)\s*,\s*(\d+)\s*,\s*(\d+)", stats_out)
        
        if match:
            return {
                "name": gpu_name,
                "usage": int(match.group(1)),
                "temp": int(match.group(2)),
                "power": float(match.group(3)),
                "freq_c": int(match.group(4)),
                "freq_m": int(match.group(5))
            }
    except:
        return None
    return None

def get_amd_info():
    """Fetches AMD iGPU/dGPU info via sysfs and lspci."""
    info = {
        "name": "AMD Radeon Graphics",
        "usage": 0,
        "temp": 0,
        "power": 0,
        "freq_c": 0,
        "freq_m": 0
    }
    
    found = False
    card_path = ""
    
    # 1. Identify AMD Card in /sys/class/drm/
    try:
        for path in glob.glob("/sys/class/drm/card*"):
            # Check vendor ID (0x1002 is AMD)
            vendor_file = os.path.join(path, "device/vendor")
            if os.path.exists(vendor_file):
                with open(vendor_file, "r") as f:
                    if "0x1002" in f.read().lower():
                        card_path = path
                        found = True
                        break
    except: pass

    if not found:
        return None

    # 2. Get Name via lspci (Cleanest way to get 'Radeon 780M' etc)
    try:
        lspci_out = subprocess.check_output("lspci -mm | grep -i 'vga\\|3d' | grep -i 'amd\\|ati'", shell=True, text=True).strip()
        # Format usually: 04:00.0 "VGA compatible controller" "Brand" "Device Name"
        # We try to grab the last quoted string or the device name
        if lspci_out:
            parts = lspci_out.split('"')
            # The device name is usually in the 4th or 6th slot depending on output
            if len(parts) >= 6:
                info["name"] = parts[5] if parts[5].strip() else parts[3]
            elif len(parts) >= 4:
                info["name"] = parts[3]
    except: 
        pass # Keep default name

    # 3. Usage (gpu_busy_percent)
    try:
        busy_path = os.path.join(card_path, "device", "gpu_busy_percent")
        if os.path.exists(busy_path):
            with open(busy_path, "r") as f:
                info["usage"] = int(f.read().strip())
    except: pass

    # 4. Temperature & Power (hwmon)
    try:
        hwmon_dir = os.path.join(card_path, "device", "hwmon", "hwmon*")
        hwmons = glob.glob(hwmon_dir)
        if hwmons:
            hm = hwmons[0]
            
            # Temp
            tpath = os.path.join(hm, "temp1_input") # Edge temp
            if os.path.exists(tpath):
                with open(tpath, "r") as f:
                    info["temp"] = int(f.read().strip()) // 1000
            
            # Power (microWatts -> Watts)
            ppath = os.path.join(hm, "power1_average")
            if os.path.exists(ppath):
                with open(ppath, "r") as f:
                    info["power"] = float(f.read().strip()) / 1000000.0

            # Frequency (clk)
            # Try freq1_input first
            fpath = os.path.join(hm, "freq1_input")
            if os.path.exists(fpath):
                with open(fpath, "r") as f:
                     info["freq_c"] = int(f.read().strip()) // 1000000 # Hz to MHz
    except: pass
    
    # Fallback for Freq if hwmon failed: pp_dpm_sclk
    if info["freq_c"] == 0:
        try:
            sclk_path = os.path.join(card_path, "device", "pp_dpm_sclk")
            if os.path.exists(sclk_path):
                with open(sclk_path, "r") as f:
                    content = f.read()
                    # format: 0: 400Mhz \n 1: 1200Mhz *
                    match = re.search(r"(\d+)Mhz\s*\*", content)
                    if match:
                        info["freq_c"] = int(match.group(1))
        except: pass

    return info

def get_storage_info():
    """Scans mounted partitions excluding loops and snaps."""
    entries = []
    # Partitions to ignore
    exclude_types = ['squashfs', 'tracefs', 'overlay', 'tmpfs', 'devtmpfs']
    exclude_mounts = ['/boot', '/boot/efi', '/run', '/dev']

    total_cap = 0
    total_used = 0
    
    for part in psutil.disk_partitions():
        if part.fstype in exclude_types or any(part.mountpoint.startswith(x) for x in exclude_mounts):
            continue
        
        # Determine Name (Root, Home, or folder name)
        name = "Data"
        if part.mountpoint == "/": name = "Root ( / )"
        elif part.mountpoint == "/home": name = "Home"
        else: name = os.path.basename(part.mountpoint).capitalize()

        try:
            usage = psutil.disk_usage(part.mountpoint)
            
            # Convert to TB/GB logic TB: 1e12 GB: 1e9
            total_tb = usage.total / 1e9
            used_tb = usage.used / 1e9
            
            total_cap += total_tb
            total_used += used_tb
            
            entries.append({
                "name": name,
                "total": total_tb,
                "used": used_tb,
                "percent": usage.percent,
                "temp": None
            })
        except: pass
    
    overall_percent = (total_used / total_cap * 100) if total_cap > 0 else 0
    return entries, total_used, total_cap, overall_percent

# ---------------------------------------------------
# BUILD OUTPUT
# ---------------------------------------------------
cpu = get_cpu_info()

# Try Nvidia first, then AMD
gpu = get_nvidia_info()
if not gpu:
    gpu = get_amd_info()

storage, tot_used, tot_cap, tot_per = get_storage_info()
mem = psutil.virtual_memory()
swap = psutil.swap_memory()

# 1. JSON TEXT (The Bar Display)
bar_text = (
    f"<span foreground='{get_color(cpu['temp'], True)}'>{CPU_ICON} {cpu['temp']:.0f}°C</span>  "
    f"<span foreground='{get_color(gpu['temp'], True) if gpu else '#777'}'>{GPU_ICON} {gpu['usage'] if gpu and gpu['usage'] > 0 else 'N/A'}%</span>  "
    f"<span foreground='{get_color(mem.percent)}'>{MEM_ICON} {mem.used/1e9:.1f}G</span>  "
    f"<span foreground='{get_color(tot_per)}'>{SSD_ICON} {tot_used:.1f}GiB</span>"
)

# 2. TOOLTIP (The Popup)
tt = []

# --- CPU ---
tt.append(f"<span foreground='{PINK}'>{CPU_ICON} CPU: {cpu['name']}</span>")
tt.append(f"  Usage: <span foreground='{get_color(cpu['usage'])}'>{cpu['usage']}%</span> | {cpu['temp']:.0f}°C")
tt.append(f"  Freq:  {cpu['freq_c']:.0f}MHz / {cpu['freq_m']:.0f}MHz")
tt.append("─" * 30)

# --- GPU ---
if gpu:
    tt.append(f"<span foreground='{PINK}'>{GPU_ICON} GPU: {gpu['name']}</span> ")
    tt.append(f"  Usage: <span foreground='{get_color(gpu['usage'])}'>{gpu['usage']}%</span> | Power: {gpu['power']:.1f}W")
    
    # Formatting for Frequency (Integrated often reports 0 max freq)
    freq_str = f"{gpu['freq_c']}MHz"
    if gpu['freq_m'] > 0:
        freq_str += f" / {gpu['freq_m']}MHz"
        
    tt.append(f"  Temp:  <span foreground='{get_color(gpu['temp'], True)}'>{gpu['temp']}°C</span> | Freq: {freq_str}")
else:
    tt.append(f"<span foreground='{PINK}'>{GPU_ICON} GPU: Not Found</span>")
tt.append("─" * 30)

# --- MEMORY ---
tt.append(f"<span foreground='{PINK}'>{MEM_ICON} MEMORY SYSTEM</span>")
tt.append(f"<tt>Type    | Used    | Total   | Util</tt>")
tt.append(f"<tt>RAM     | {mem.used/1e9:4.1f} GB | {mem.total/1e9:4.1f} GB | <span foreground='{get_color(mem.percent)}'>{mem.percent}%</span></tt>")
tt.append(f"<tt>Swap    | {swap.used/1e9:4.1f} GB | {swap.total/1e9:4.1f} GB | <span foreground='{get_color(swap.percent)}'>{swap.percent}%</span></tt>")
tt.append("─" * 30)

# --- STORAGE ---
tt.append(f"<span foreground='{PINK}'>{SSD_ICON} STORAGE ({tot_per:.0f}%)</span>")
tt.append(f"<tt>Drive        | Used   | Free   | Util</tt>")
for disk in storage:
    d_name = (disk['name'][:10] + '..') if len(disk['name']) > 10 else disk['name']
    
    tt.append(
        f"<tt>{d_name:<12} | "
        f"{disk['used']:<4.1f} T | "
        f"{(disk['total'] - disk['used']):<4.1f} T | "
        f"<span foreground='{get_color(disk['percent'])}'>{disk['percent']:>2.0f}%</span></tt>"
    )

# PRINT JSON
print(json.dumps({
    "text": bar_text,
    "tooltip": "\n".join(tt),
    "class": "custom-sysmon",
    "alt": "sysmon"
}))
