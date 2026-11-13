# Пункт 3. Вимірювання енерговитрат через RAPL (лічильник енергії процесора).
# Запуск: python3 04_energy.py bin/prog_O0
# Потрібна фізична машина (у віртуалці RAPL немає).
import sys
import time
import subprocess
import resource
import os

RAPL = "/sys/class/powercap/intel-rapl:0/energy_uj"   # енергія процесора в мікроджоулях

def read_energy():
    f = open(RAPL)
    value = int(f.read())
    f.close()
    return value / 1000000.0       # переводимо в джоулі

prog = sys.argv[1]

# 1. міряємо споживання, коли комп'ютер простоює (10 секунд)
print("Міряю простій 10 секунд, нічого не чіпайте...")
e1 = read_energy()
time.sleep(10)
e2 = read_energy()
p_idle = (e2 - e1) / 10.0
print("Потужність простою: %.2f Вт" % p_idle)

# 2. запускаємо програму і міряємо енергію
e1 = read_energy()
t1 = time.time()
subprocess.run([prog], stdout=subprocess.DEVNULL)
t2 = time.time()
e2 = read_energy()

t = t2 - t1
e_sys = e2 - e1
p_sys = e_sys / t

# 3. енергія тільки програми = все - те, що б витратили на простої
e_prog = e_sys - p_idle * t

# 4. друга оцінка: беремо частку процесорного часу, який використала програма
usage = resource.getrusage(resource.RUSAGE_CHILDREN)
cpu_time = usage.ru_utime + usage.ru_stime
e_prog2 = e_sys * cpu_time / (t * os.cpu_count())

print("")
print("Час роботи: %.2f с" % t)
print("3.1 Система: E = %.1f Дж, P = %.1f Вт" % (e_sys, p_sys))
print("3.2 Програма (спосіб 1, мінус простій): E = %.1f Дж" % e_prog)
print("3.2 Програма (спосіб 2, частка CPU-часу): E = %.1f Дж" % e_prog2)
