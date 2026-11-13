#!/bin/bash
# Пункт 2. Статистика виконання.
# Запуск: bash 03_stats.sh bin/prog_O0
BIN=$1
NAME=$(basename $BIN)
mkdir -p out/$NAME

echo "=== 2.1 time --verbose ==="
/usr/bin/time --verbose ./$BIN 2> out/$NAME/time.txt
cat out/$NAME/time.txt

echo "=== 2.2 perf stat -d ==="
perf stat -d ./$BIN 2> out/$NAME/perf_stat.txt
cat out/$NAME/perf_stat.txt

echo "=== 2.3 perf record + perf report ==="
perf record -g -o out/$NAME/perf_report.data ./$BIN
perf report -i out/$NAME/perf_report.data --stdio --no-children > out/$NAME/perf_report.txt
head -40 out/$NAME/perf_report.txt
