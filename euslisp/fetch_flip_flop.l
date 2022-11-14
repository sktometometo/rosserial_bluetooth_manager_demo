#!/usr/bin/env roseus

(require "package://fetcheus/fetch-interface.l")
(require "package://rosserial_bluetooth_manager/euslisp/utils.l")


(fetch-init)

(setq *sleep-time* (ros::get-param "~sleep_time" 1))
(setq *target-device-address* (ros::get-param "~target_device_address" "A4:CF:12:44:33:F2"))
(setq *robot-name* (ros::get-param "/robot/name"))
(setq *target-node-name* (ros::get-param "~target_node_name" "serial_node_for_A4_CF_12_44_33_F2"))

(ros::advertise (format nil "~A/output" *target-node-name*) std_msgs::String 1)

(let (res msg)
  (while (ros::ok)
    (unix:sleep *sleep-time*)
    (ros::spin-once)
    (setq res (connect-device *target-device-address*))
    (setq msg (one-shot-subscribe (format nil "~A/output" *target-node-name*)))
    (send *ri* :speak (format nil "Read text as ~A from device" (send msg :data)))
    (ros::ros-info (format nil "Read text as ~A from device" (send msg :data)))
    (send msg :data *robot-name*)
    (ros::publish (format nil "~A/output" *target-node-name*) msg)
    (send *ri* :speak (format nil "Write text as ~A to device" (send msg :data)))
    (ros::ros-info (format nil "Write text as ~A to device" (send msg :data)))
    (ros::spin-once)
    (setq res (disconnect-device *target-device-address*))
    ))
