import subprocess, sys, time
prog, dur = sys.argv[1], float(sys.argv[2])
t0 = time.time(); n = 0
while time.time() - t0 < dur:
    subprocess.run([prog], stdout=subprocess.DEVNULL); n += 1
t = time.time() - t0
print(f"{prog}: runs={n}, total={t:.1f} s, per run={t/n:.3f} s")
