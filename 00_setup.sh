#!/bin/bash
# Встановлення потрібних програм (Ubuntu). Запускати один раз.
sudo apt update
sudo apt install -y build-essential git time linux-tools-common linux-tools-generic linux-tools-$(uname -r)
git clone https://github.com/brendangregg/FlameGraph ~/FlameGraph

# дозволяємо perf працювати без root
sudo sysctl -w kernel.perf_event_paranoid=-1
sudo sysctl -w kernel.kptr_restrict=0
# дозволяємо читати лічильники енергії (RAPL)
sudo chmod -R a+r /sys/class/powercap/
