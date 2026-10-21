import os
import sys
import time
import resource
import subprocess

RAPL_PATH = "/sys/class/powercap/intel-rapl:0/energy_uj"

def has_rapl():
    return os.path.exists(RAPL_PATH) and os.access(RAPL_PATH, os.R_OK)

prog = sys.argv[1]

if has_rapl():
    with open(RAPL_PATH, "r") as f:
        e1 = int(f.read().strip())
    time.sleep(5)
    with open(RAPL_PATH, "r") as f:
        e2 = int(f.read().strip())
    p_idle = (e2 - e1) / 5.0 / 1_000_000.0

    with open(RAPL_PATH, "r") as f:
        e_start = int(f.read().strip())
    t_start = time.time()
    subprocess.run([prog], stdout=subprocess.DEVNULL)
    t_end = time.time()
    with open(RAPL_PATH, "r") as f:
        e_end = int(f.read().strip())

    t = t_end - t_start
    e_sys = (e_end - e_start) / 1_000_000.0
    p_sys = e_sys / t if t > 0 else 0.0
    e_prog1 = max(0.0, e_sys - p_idle * t)
else:
    p_idle = 15.0
    p_load = 42.0
    t_start = time.time()
    subprocess.run([prog], stdout=subprocess.DEVNULL)
    t_end = time.time()

    t = t_end - t_start
    usage = resource.getrusage(resource.RUSAGE_CHILDREN)
    cpu_time = usage.ru_utime + usage.ru_stime
    ratio = min(1.0, cpu_time / t) if t > 0 else 1.0

    p_sys = p_idle + (p_load - p_idle) * ratio
    e_sys = p_sys * t
    e_prog1 = (p_sys - p_idle) * t

usage = resource.getrusage(resource.RUSAGE_CHILDREN)
cpu_time = usage.ru_utime + usage.ru_stime
e_prog2 = e_sys * min(1.0, cpu_time / t) if t > 0 else 0.0

print(f"Час роботи: {t:.3f} с")
print(f"Потужність простою: {p_idle:.2f} Вт")
print(f"3.1 Система: E = {e_sys:.2f} Дж, P = {p_sys:.2f} Вт")
print(f"3.2 Програма (спосіб 1, мінус простій): E = {e_prog1:.2f} Дж")
print(f"3.2 Програма (спосіб 2, частка CPU-часу на ядро): E = {e_prog2:.2f} Дж")