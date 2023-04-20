#!/bin/bash

# Get current date and time
# 'cut' property is used to extract the number of characters given in value
miliseconds=$(date +%N | cut -b1-3)
date_time=$(date +"%Y-%m-%d %H:%M:%S.$miliseconds")

# Print current date
echo "Current date & time: $date_time"

# Get CPU usage statistics
cpu1=$(top -bn1 | grep load)
cpu=$(top -bn1 | grep load | awk '{printf "%.2f%%\n", $(NF-2)}')
cpus=$(top -bn1 | grep 'Cpu(s)')
sum=$(top -bn1 | grep "Cpu(s)" | awk -v n=$(nproc) '{sum=0; for(i=2;i<=n+1;i++){sum+=$i}; printf "%.2f%%\n", sum}')

echo "CPU: $cpu1"
echo "CPU Usage: $cpu"
echo "CPUs: $cpus"
echo "Sum: $sum"
