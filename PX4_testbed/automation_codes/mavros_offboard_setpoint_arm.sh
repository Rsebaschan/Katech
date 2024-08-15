#!/bin/bash

open_terminal_tab() {
    local command=$1
    local title=$2
    gnome-terminal --tab --title="$title" -- bash -c "$command; exec bash"
}

# Step 1: Start MAVROS
mavros_command="roslaunch mavros apm.launch fcu_url:=udp://:14540@"
open_terminal_tab "$mavros_command" "MAVROS"

# Wait a few seconds to ensure MAVROS is fully started
sleep 3

# Step 2: Set Mode to OFFBOARD
offboard_command="rosservice call /mavros/set_mode \"custom_mode: 'OFFBOARD'\""
open_terminal_tab "$offboard_command" "Set OFFBOARD Mode"

sleep 0.5

# Step 3: Publish Takeoff Setpoint
setpoint_command="rostopic pub -r 10 /mavros/setpoint_position/local geometry_msgs/PoseStamped \"{
  header: {
    seq: 0,
    stamp: {
      secs: 0,
      nsecs: 0
    },
    frame_id: ''
  },
  pose: {
    position: {
      x: 0.0,
      y: 0.0,
      z: 10.0
    },
    orientation: {
      x: 0.0,
      y: 0.0,
      z: 0.0,
      w: 1.0
    }
  }
}\""
open_terminal_tab "$setpoint_command" "Publish Setpoint"

sleep 0.5

# Step 4: Arm the Vehicle
arm_command="rosservice call /mavros/cmd/arming \"value: true\""
open_terminal_tab "$arm_command" "Arm Vehicle"

pose_echo="rostopic echo /mavros/local_position/pose -c"
open_terminal_tab "$pose_echo" "Pose Echo"



