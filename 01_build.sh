#!/bin/bash
# Збираємо три версії програми.
# -g -fno-omit-frame-pointer потрібні, щоб perf бачив стек викликів
# -fno-inline забороняє вбудовувати функції, інакше їх не буде видно на FlameGraph
mkdir -p bin out
FLAGS="-g -fno-omit-frame-pointer -fno-inline"

gcc -O0 $FLAGS prog.c -o bin/prog_O0                        # до оптимізації
gcc -O3 -march=native $FLAGS prog.c -o bin/prog_O3          # тільки ключі
gcc -O3 -march=native $FLAGS -DOPT prog.c -o bin/prog_O3_opt  # ключі + зміна коду

for p in bin/*; do
    echo $p
    ./$p
done
