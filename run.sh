#!/bin/bash
set -e

mkdir -p bin out
FLAGS="-g -fno-omit-frame-pointer -fno-inline"

echo "=== Компіляція ==="
gcc -O0 $FLAGS prog.c -o bin/prog_O0
gcc -O3 -march=native $FLAGS prog.c -o bin/prog_O3
gcc -O3 -march=native $FLAGS -DOPT prog.c -o bin/prog_O3_opt

for p in prog_O0 prog_O3 prog_O3_opt; do
    echo "=== Заміри для $p ==="
    mkdir -p out/$p

    # Заміри часу через time
    /usr/bin/time --verbose ./bin/$p 2> out/$p/time.txt

    # Статистика perf stat (вона в WSL працює нормально)
    perf stat -d ./bin/$p 2> out/$p/perf_stat.txt

    # Енерговитрати через наш python-скрипт
    python3 energy.py ./bin/$p | tee out/$p/energy.txt

    # Генерація асемблера
    objdump -d -M intel --no-show-raw-insn ./bin/$p > out/$p/asm.txt
done

echo ""
echo "================ РЕЗУЛЬТАТИ ================"
for p in prog_O0 prog_O3 prog_O3_opt; do
    echo ">>> $p <<<"
    grep -E "User time|System time|Elapsed|Maximum resident|Percent of CPU" out/$p/time.txt
    cat out/$p/perf_stat.txt
    cat out/$p/energy.txt
    echo ""
done