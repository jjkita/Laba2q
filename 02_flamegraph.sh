#!/bin/bash
# Пункт 1. Побудова FlameGraph.
# Запуск: bash 02_flamegraph.sh bin/prog_O0
# Для всієї системи: bash 02_flamegraph.sh bin/prog_O0 system
BIN=$1
NAME=$(basename $BIN)
FG=~/FlameGraph
mkdir -p out/$NAME

if [ "$2" == "system" ]; then
    # записуємо всю систему 20 секунд, паралельно запускаємо програму
    perf record -F 99 -a -g -o out/$NAME/perf_sys.data -- sleep 20 &
    sleep 1
    ./$BIN
    wait
    DATA=out/$NAME/perf_sys.data
    SVG=out/$NAME/flame_system.svg
else
    # тільки наша програма
    perf record -F 997 -g -o out/$NAME/perf.data ./$BIN
    DATA=out/$NAME/perf.data
    SVG=out/$NAME/flame.svg
fi

# 1) перетворюємо дані perf у текст
perf script -i $DATA > out/$NAME/out.perf
# 2) згортаємо однакові стеки
$FG/stackcollapse-perf.pl out/$NAME/out.perf > out/$NAME/out.folded
# 3) малюємо svg
$FG/flamegraph.pl out/$NAME/out.folded > $SVG

echo "Готово: $SVG (відкрийте у браузері)"
