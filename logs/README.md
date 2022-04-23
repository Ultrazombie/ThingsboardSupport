# Parse logs


Here you can find scripts to help you check the system load.

# parseThingsboardLog 
The script allows you to find the average and maximum number of processed, saved, failed, etc. messages in the log file for different queues

By default the script uses the thingsboard.log file which is located in the folder with the script. you can change the path to this file in the LOGS_PATH variable of the script itself, or set the path when the script runs. for example:
`./parseThingsboardLog ~/path/to/logs/thingsboard_log_name.log`
