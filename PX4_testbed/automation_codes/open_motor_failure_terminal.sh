#!/bin/bash

# 첫 번째 스크립트를 새로운 터미널에서 실행
gnome-terminal -- bash -c "/home/hmcl/PX4_testbed/automation_codes/motor_failure.sh; exec bash" &
sleep 2

# 첫 번째 터미널 PID 확인
THIRD_TERMINAL_PID=$(pgrep -n gnome-terminal)
echo $THIRD_TERMINAL_PID > third_terminal_pid.txt
echo "Third terminal PID: $THIRD_TERMINAL_PID"
