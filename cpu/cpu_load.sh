#!/bin/bash

while true; do
  clear
  # Get current date and time
  # 'cut' property is used to extract the number of characters given in value
  miliseconds=$(date +%N | cut -b1-3)
  date_time=$(date +"%Y-%m-%d %H:%M:%S.$miliseconds")

  # Print current date
  echo "Current date & time: $date_time"

  # Load command
  load=$(top -bn1 | grep load)
  echo -e "$load"

  # Total cores in CPU
  total_cores=$(grep -c ^processor /proc/cpuinfo)

  # Values by minutes
  # Ask for minutes load
  min_from_load=$(echo "$load" | awk '{print $6}')

  if [ "$min_from_load" = "min," ]; then
    one_minute_load=$(echo "$load" | awk '{print $11}' | tr ',' '.' | sed 's/.$//')
    one_minute_load_and_cores=$(echo "$one_minute_load"/"$total_cores cores")

    five_minutes_load=$(echo "$load" | awk '{print $12}' | tr ',' '.' | sed 's/.$//')
    five_minutes_load_and_cores=$(echo "$five_minutes_load"/"$total_cores cores")

    fifteen_minutes_load=$(echo "$load" | awk '{print $13}' | tr ',' '.' | sed 's/.$//')
    fifteen_minutes_load_and_cores=$(echo "$fifteen_minutes_load"/"$total_cores cores")
  else
    one_minute_load=$(echo "$load" | awk '{print $10}' | tr ',' '.' | sed 's/.$//')
    one_minute_load_and_cores=$(echo "$one_minute_load"/"$total_cores cores")

    five_minutes_load=$(echo "$load" | awk '{print $11}' | tr ',' '.' | sed 's/.$//')
    five_minutes_load_and_cores=$(echo "$five_minutes_load"/"$total_cores cores")

    fifteen_minutes_load=$(echo "$load" | awk '{print $12}' | tr ',' '.' | sed 's/.$//')
    fifteen_minutes_load_and_cores=$(echo "$fifteen_minutes_load"/"$total_cores cores")
  fi

  stream_name="cpu_stats"

  # Convert into JSON object
  json_stats="{ \"date\": \"$date_time\", \"cpu_load_1\": \"$one_minute_load_and_cores\", \"cpu_load_5\": \"$five_minutes_load_and_cores\", \"cpu_load_15\": \"$fifteen_minutes_load_and_cores\" }"
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

  # Print results
  echo -e "\n================="
  echo -e "\033[34mAverage CPU Load by periods\033[0m"

  echo -e "\n-----------------"
  echo -e "\033[32mAverage CPU load in last 1 minute:\033[0m ------------- $one_minute_load_and_cores"
  echo -e "\n"

  echo -e "\033[32mAverage CPU load in last 5 minutes:\033[0m ------------ $five_minutes_load_and_cores"
  echo -e "\n"

  echo -e "\033[32mAverage CPU load in last 15 minutes:\033[0m ------------ $fifteen_minutes_load_and_cores"
  echo -e "\n-----------------"
  echo -e "\n"
  echo -e "=================\n"

  sleep 60
done