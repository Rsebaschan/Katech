#!/bin/bash

# 첫 번째 스크립트를 새로운 터미널에서 실행
gnome-terminal -- bash -c "/home/hmcl/PX4_testbed/automation_codes/roscore_for_simulink.sh; exec bash" &
sleep 2

# 첫 번째 터미널 PID 확인
FOURTH_TERMINAL_PID=$(pgrep -n gnome-terminal)
echo $FOURTH_TERMINAL_PID > fourth_terminal_pid.txt
echo "Fourth terminal PID: $FOURTH_TERMINAL_PID"
