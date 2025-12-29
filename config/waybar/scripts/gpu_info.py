#!/usr/bin/env python3
import json
import subprocess
import re
import glob
import os
import sys

def get_nvidia_info():
    """Fetches Nvidia GPU info via nvidia-smi."""
    try:
        # Check if nvidia-smi exists first to avoid unnecessary errors
        subprocess.check_call(["which", "nvidia-smi"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
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

    # 2. Get Name via lspci
    try:
        lspci_out = subprocess.check_output("lspci -mm | grep -i 'vga\\|3d' | grep -i 'amd\\|ati'", shell=True, text=True).strip()
        if lspci_out:
            parts = lspci_out.split('"')
            if len(parts) >= 6:
                info["name"] = parts[5] if parts[5].strip() else parts[3]
            elif len(parts) >= 4:
                info["name"] = parts[3]
    except: 
        pass 

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
            tpath = os.path.join(hm, "temp1_input") 
            if os.path.exists(tpath):
                with open(tpath, "r") as f:
                    info["temp"] = int(f.read().strip()) // 1000
            
            # Power (microWatts -> Watts)
            ppath = os.path.join(hm, "power1_average")
            if os.path.exists(ppath):
                with open(ppath, "r") as f:
                    info["power"] = float(f.read().strip()) / 1000000.0

            # Frequency (clk)
            fpath = os.path.join(hm, "freq1_input")
            if os.path.exists(fpath):
                 with open(fpath, "r") as f:
                      info["freq_c"] = int(f.read().strip()) // 1000000 
    except: pass
    
    # Fallback for Freq
    if info["freq_c"] == 0:
        try:
            sclk_path = os.path.join(card_path, "device", "pp_dpm_sclk")
            if os.path.exists(sclk_path):
                with open(sclk_path, "r") as f:
                    content = f.read()
                    match = re.search(r"(\d+)Mhz\s*\*", content)
                    if match:
                        info["freq_c"] = int(match.group(1))
        except: pass

    return info

def main():
    # Try Nvidia first, then AMD
    gpu_data = get_nvidia_info()
    if not gpu_data:
        gpu_data = get_amd_info()

    if gpu_data:
        # Format text for the bar (Usage %)
        text = f"{gpu_data['usage']}%"
        
        # Format tooltip
        tooltip = (f"{gpu_data['name']}\n"
                   f"Usage: {gpu_data['usage']}%\n"
                   f"Temp: {gpu_data['temp']}°C\n"
                   f"Power: {gpu_data['power']:.1f} W\n"
                   f"Clock: {gpu_data['freq_c']} MHz")
        
        # JSON Output
        print(json.dumps({"text": text, "tooltip": tooltip, "class": "custom-gpu"}))
    else:
        # No GPU found
        print(json.dumps({"text": "N/A", "tooltip": "No GPU detected"}))

if __name__ == "__main__":
    main()
