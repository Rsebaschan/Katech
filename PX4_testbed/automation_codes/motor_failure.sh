#!/bin/bash

open_terminal_tab() {
    local command=$1
    local title=$2
    gnome-terminal --tab --title="$title" -- bash -c "echo -ne '\033]0;$title\007'; $command; exec bash"
}

# Motor Failure 명령 실행
motor_failure_number=$(cat motor_failure_number.txt)
motor_failure_number1=$(cat motor_failure_number1.txt)
motor_failure_number2=$(cat motor_failure_number2.txt)

motor_failure_command="rostopic pub /motor_failure/motor_number std_msgs/Int32 \"data: $motor_failure_number\""
open_terminal_tab "$motor_failure_command" "Publish Motor Failure"

sleep 3

motor_failure_command1="rostopic pub /motor_failure/motor_number1 std_msgs/Int32 \"data: $motor_failure_number1\""
open_terminal_tab "$motor_failure_command1" "Publish Motor Failure_1"

sleep 3

motor_failure_command2="rostopic pub /motor_failure/motor_number2 std_msgs/Int32 \"data: $motor_failure_number2\""
open_terminal_tab "$motor_failure_command2" "Publish Motor Failure_2"
