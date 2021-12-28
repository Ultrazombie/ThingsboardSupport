#!/bin/bash

HOST_NAME=localhost
ACCESS_TOKEN=T2_TEST_TOKEN

#for (( a = 1; a < 30; a++ ))
while true
do
    mosquitto_pub -d -q 1 -h "$HOST_NAME" -p "1883" -t "v1/devices/me/telemetry" -u "$ACCESS_TOKEN" -m {"temperature":"${RANDOM:0:2}"}
    sleep 1s
done 

