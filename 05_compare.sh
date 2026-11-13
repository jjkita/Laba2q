#!/bin/bash
# Пункт 4. Порівняння до і після оптимізації.
bash 01_build.sh > /dev/null

for p in prog_O0 prog_O3 prog_O3_opt; do
    echo "######## $p"
    bash 02_flamegraph.sh bin/$p
    bash 03_stats.sh bin/$p > out/$p/stats_all.txt
    python3 04_energy.py bin/$p | tee out/$p/energy.txt
    # асемблер функцій множення
    objdump -d -M intel --no-show-raw-insn bin/$p > out/$p/asm.txt
done

echo ""
echo "=== Час виконання ==="
for p in prog_O0 prog_O3 prog_O3_opt; do
    echo -n "$p: "
    grep "Elapsed" out/$p/time.txt
done

echo "=== Інструкції, цикли, IPC ==="
for p in prog_O0 prog_O3 prog_O3_opt; do
    echo $p
    grep -E "instructions|cycles" out/$p/perf_stat.txt
done

# різниця між FlameGraph до і після
~/FlameGraph/difffolded.pl out/prog_O0/out.folded out/prog_O3_opt/out.folded | ~/FlameGraph/flamegraph.pl > out/diff.svg
echo "Різницевий FlameGraph: out/diff.svg"
