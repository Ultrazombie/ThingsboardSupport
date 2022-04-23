# Send telemetry


Here you can find scripts that help you to send telemetry to the test devices in different ways. Currently provided methods of sending using mqtt and http protocol.


# MQTT 
Mosquito is used to send the data. If you do not have the client installed, install it:
`sudo apt update -y && sudo apt install mosquitto-clients -y`

- -h -- you hostname where thingsboard are deployed;
- -p -- port MQTT service. By default for MQTT is 1883 and for MQTTS is 8883;
- -t -- MQTT topic. For telemetry used v1/devices/me/telemetry. For attributes used v1/devices/me/attributes ;
- -u -- device token for authentefication;
- -m -- message if json format;
- -f -- you can use a json file instead of a message, and in the value specify the path to this file;

For more information, use the documentation on our website: https://thingsboard.io/docs/reference/mqtt-api/

