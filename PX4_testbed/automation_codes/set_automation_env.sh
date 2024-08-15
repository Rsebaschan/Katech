#!/bin/bash

# 첫 번째 스크립트를 새로운 터미널에서 실행
gnome-terminal -- bash -c "/home/hmcl/PX4_testbed/automation_codes/set_gazebo_windy.sh; exec bash" &
sleep 2

# 첫 번째 터미널 PID 확인
FIRST_TERMINAL_PID=$(pgrep -n gnome-terminal)
echo $FIRST_TERMINAL_PID > first_terminal_pid.txt
echo "First terminal PID: $FIRST_TERMINAL_PID"

sleep 5 #가제보 gui를 키면 슬립줄이 잇는게 낫다. 추후에 에러가 나온다.

# 두 번째 스크립트를 새로운 터미널에서 실행
gnome-terminal -- bash -c "/home/hmcl/PX4_testbed/automation_codes/mavros_offboard_setpoint_arm.sh; exec bash" &
sleep 2

# 두 번째 터미널 PID 확인
SECOND_TERMINAL_PID=$(pgrep -n gnome-terminal)
echo $SECOND_TERMINAL_PID > second_terminal_pid.txt
echo "Second terminal PID: $SECOND_TERMINAL_PID"
