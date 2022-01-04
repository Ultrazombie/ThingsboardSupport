#!/bin/bash

HOST_NAME=127.0.0.1

ACCESS_TOKEN1=T1_TEST_TOKEN
ACCESS_TOKEN2=T2_TEST_TOKEN
ACCESS_TOKEN3=C1_TEST_TOKEN
ACCESS_TOKEN_DH=DHT11_DEMO_TOKEN
ACCESS_TOKEN_RAS=RASPBERRY_PI_DEMO_TOKEN



#for (( a = 1; a < 30; a++ ))
while true
do
    mosquitto_pub -d -q 1 -h "$HOST_NAME" -p "1883" -t "v1/devices/me/telemetry" -u "$ACCESS_TOKEN1" -m "{"temperature":"${RANDOM:0:2}"}"
    mosquitto_pub -d -q 1 -h "$HOST_NAME" -p "1883" -t "v1/devices/me/telemetry" -u "$ACCESS_TOKEN2" -m {"temperature":"${RANDOM:0:2}"}
    mosquitto_pub -d -q 1 -h "$HOST_NAME" -p "1883" -t "v1/devices/me/telemetry" -u "$ACCESS_TOKEN3" -m {"c1":"${RANDOM:0:2}"}
    mosquitto_pub -d -q 1 -h "$HOST_NAME" -p "1883" -t "v1/devices/me/telemetry" -u "$ACCESS_TOKEN_DH" -m {"DH":"${RANDOM:0:2}"}
    mosquitto_pub -d -q 1 -h "$HOST_NAME" -p "1883" -t "v1/devices/me/telemetry" -u "$ACCESS_TOKEN_RAS" -m {"RAS":"${RANDOM:0:2}"}
    sleep 0.001
done 

