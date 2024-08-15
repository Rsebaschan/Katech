#!/bin/bash

open_terminal_tab() {
    local command=$1
    local title=$2
    gnome-terminal --tab --title="$title" -- bash -c "echo -ne '\033]0;$title\007'; $command; exec bash"
}


# Motor Failure 명령 실행
motor_failure_command="rostopic pub /motor_failure/motor_number std_msgs/Int32 \"data: 0\""
open_terminal_tab "$motor_failure_command" "Publish Motor Recovery"

# 한번에 두개 고장 나니깐 걍 바로 추락이다.
# 현장감을 위해 하나씩 고장 내보겠다
sleep 3

# Motor Failure 명령 실행
motor_failure_command1="rostopic pub /motor_failure/motor_number1 std_msgs/Int32 \"data: 0\""
open_terminal_tab "$motor_failure_command1" "Publish Motor Recovery_1"