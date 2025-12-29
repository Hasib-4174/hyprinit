#!/usr/bin/env python3
import psutil
import json
import platform
# import cpuinfo # explicit cpu info (optional) or standard read

def get_cpu_name():
    """Reads the CPU model name from /proc/cpuinfo for Linux."""
    try:
        with open("/proc/cpuinfo", "r") as f:
            for line in f:
                if "model name" in line:
                    return line.split(":")[1].strip()
    except:
        return platform.processor()

def get_cpu_temps():
    """
    Tries to map temperatures to cores.
    Intel 'coretemp' often gives per-core temps.
    AMD 'k10temp' usually gives a single 'Tctl' or 'Tdie' package temp.
    Returns: A list of temps matching core count, or a fallback single temp.
    """
    temps = psutil.sensors_temperatures()
    core_temps = []

    # Priority 1: Intel 'coretemp' (Per core data usually available)
    if 'coretemp' in temps:
        entries = temps['coretemp']
        # Filter for actual cores, usually labeled 'Core X'
        # Note: Hyperthreading means 2 threads share 1 temp, we handle this logic later
        sorted_entries = sorted([e for e in entries if 'Core' in e.label], key=lambda x: x.label)
        core_temps = [e.current for e in sorted_entries]

    # Priority 2: AMD 'k10temp' (Usually package temp only)
    elif 'k10temp' in temps:
        entries = temps['k10temp']
        # Tctl or Tdie is usually the best reference
        pkg_temp = next((e.current for e in entries if e.label in ['Tctl', 'Tdie', 'edge']), None)
        if pkg_temp is None and entries:
            pkg_temp = entries[0].current
        if pkg_temp:
             # Return single value to apply to all
             return pkg_temp 

    return core_temps

def main():
    # 1. Get CPU Name
    cpu_name = get_cpu_name()

    # 2. Get Usage (Blocking call 1s to get accurate reading)
    # percpu=True gives a list of usage per thread
    usages = psutil.cpu_percent(interval=1, percpu=True)
    total_usage = sum(usages) / len(usages)

    # 3. Get Temperatures
    raw_temps = get_cpu_temps()
    
    # logic to map temps to threads
    # specific_temps maps thread index -> temp value
    final_temps = []
    
    if isinstance(raw_temps, float) or isinstance(raw_temps, int):
        # Case: Single package temp (AMD Common) -> Assign to all
        final_temps = [raw_temps] * len(usages)
    elif raw_temps:
        # Case: List of core temps (Intel)
        # Often physical cores < logical threads (Hyperthreading)
        # We assume Core 0 temp applies to Thread 0 and Thread 1 if count mismatches
        ratio = len(usages) // len(raw_temps)
        if ratio < 1: ratio = 1
        for t in raw_temps:
            final_temps.extend([t] * ratio)
        # Pad if missing
        while len(final_temps) < len(usages):
            final_temps.append(final_temps[-1])
    else:
        # Fallback if no sensors found
        final_temps = [0] * len(usages)

    # 4. Format Tooltip Grid (2 Columns)
    # Header
    tooltip_lines = [f"<b>{cpu_name}</b> - {total_usage:.1f}%"]
    tooltip_lines.append(f"Cores: {len(usages)}")
    tooltip_lines.append("") # Spacer
    
    # Rows
    rows = []
    for i in range(0, len(usages), 2):
        # Left Column
        u1 = usages[i]
        t1 = final_temps[i]
        # Spacing adjustment for alignment
        col1 = f"Core {i:<2}: {u1:>3.0f}% ({t1}°C)"
        
        # Right Column (Check if exists)
        if i + 1 < len(usages):
            u2 = usages[i+1]
            t2 = final_temps[i+1]
            col2 = f"Core {i+1:<2}: {u2:>3.0f}% ({t2}°C)"
            
            rows.append(f"{col1}   |   {col2}")
        else:
            rows.append(f"{col1}")

    tooltip_body = "\n".join(rows)

    # 5. Output JSON
    output = {
        "text": f"{total_usage:.0f}%",
        "tooltip": f"{tooltip_lines[0]}\n{tooltip_lines[1]}\n\n<tt>{tooltip_body}</tt>",
        "class": "custom-cpu"
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    main()
