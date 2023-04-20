#!/bin/bash

# Get current date and time
# 'cut' property is used to extract the number of characters given in value
miliseconds=$(date +%N | cut -b1-3)
date_time=$(date +"%Y-%m-%d %H:%M:%S.$miliseconds")

# Print current date
echo "Current date & time: $date_time"

# Get CPU usage statistics
cpu=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')

echo "CPU Usage: $cpu"
