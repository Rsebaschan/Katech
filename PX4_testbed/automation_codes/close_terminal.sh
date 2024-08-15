#!/bin/bash

# 첫 번째 터미널 PID를 파일에서 읽고 종료
FIRST_TERMINAL_PID=$(cat first_terminal_pid.txt)
kill $FIRST_TERMINAL_PID
echo "First terminal with PID $FIRST_TERMINAL_PID has been terminated."

# 두 번째 터미널 PID를 파일에서 읽고 종료
SECOND_TERMINAL_PID=$(cat second_terminal_pid.txt)
kill $SECOND_TERMINAL_PID
echo "Second terminal with PID $SECOND_TERMINAL_PID has been terminated."

# 세 번째 터미널 PID를 파일에서 읽고 종료
THIRD_TERMINAL_PID=$(cat third_terminal_pid.txt)
kill $THIRD_TERMINAL_PID
echo "Third terminal with PID $THIRD_TERMINAL_PID has been terminated."


# 세 번째 터미널 PID를 파일에서 읽고 종료
FOURTH_TERMINAL_PID=$(cat fourth_terminal_pid.txt)
kill $FOURTH_TERMINAL_PID
echo "Fourth terminal with PID $FOURTH_TERMINAL_PID has been terminated."


