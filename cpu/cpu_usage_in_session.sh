#!/bin/bash

total_cores=$(grep -c ^processor /proc/cpuinfo)
cores=$(($total_cores - 1))

while true; do
  clear

  # cpus=$(cat /proc/stat | grep "^cpu[0-$cores]")
  mapfile -t cpus < <(cat /proc/stat | grep "^cpu[0-$cores]")
  uptime_seconds=$(awk '{print $1}' /proc/uptime)
  uptime_seconds=${uptime_seconds%.*}
  miliseconds=$(($uptime_seconds * 1000))
  echo -e "Miliseconds: $miliseconds"

  stream_name="cpu_stats"

  for cpu in "${cpus[@]}"
  do
    # Get current date and time
    # 'cut' property is used to extract the number of characters given in value
    miliseconds_for_date=$(date +%N | cut -b1-3)
    date_time=$(date +"%Y-%m-%d %H:%M:%S.$miliseconds_for_date")

    # Print current date
    echo "Current date & time: $date_time"
    
    # Cores CPU stats
    core=$(echo $cpu | awk '{print $1}')
    just_cpu_idle_ms=$(echo $cpu | awk '{print $5}')
    usage_ms=$(echo $miliseconds - $just_cpu_idle_ms | bc)
    core_usage=$(echo "scale=4; ($just_cpu_idle_ms/$miliseconds) * 100" | bc | sed 's/$/%/')
    echo -e "$core_usage"
    
    # Convert into JSON object
    json_stats="{ \"date\": \"$date_time\", \"$core\": \"$core_usage\", \"usage_ms\": \"$usage_ms\", \"session_ms\": \"$miliseconds\" }"
    printf '%s\n' "$json_stats"
    
    # Send data to kinesis
    response=$(aws kinesis put-record --stream-name "$stream_name" --partition-key "$date_time" --data "$json_stats" 2>&1)

    # Check if response contains "SequenceNumber" string
    if echo "$response" | grep -q "SequenceNumber"; then
      # Response contains "SequenceNumber" string - Ok
      echo -e "\033[32mSuccesfully data sent to AWS Kinesis\033[0m - Response: $response"
    else
      # Response doesn't contains "SequenceNumber" string - Error
      echo -e "\e[31mError at send data to AWS Kinesis\033[0m - Error: $response"
    fi
  done
  
  sleep 10
done
