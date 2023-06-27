#!/bin/bash

# Functions
# Print stats of arguments passed
function print_stat() {
    local name=$1
    local usage=$2

    echo -e "\033[32m${name}\033[0m$usage"
}

while true; do
  clear
  
  # Get current date and time
  # 'cut' property is used to extract the number of characters given in value
  miliseconds=$(date +%N | cut -b1-3)
  date_time=$(date +"%Y-%m-%d %H:%M:%S.$miliseconds")

  # Print current date
  echo "Current date & time: $date_time"

  # Both memories, physic general and swap
  usage_memory=$(free)
  echo -e "General usage memory: \n$usage_memory"

  # Just physical memory
  physical_memory=$(free | grep -i "mem")

  total_memory=$(echo "$physical_memory" | awk '{print $2}')
  used_memory=$(echo "$physical_memory" | awk '{print $3}')
  used_memory_percentage=$(echo "scale=4; ($used_memory/$total_memory) * 100" | bc)
  free_memory=$(echo "$physical_memory" | awk '{print $4}')
  free_memory_percentage=$(echo "scale=4; ($free_memory/$total_memory) * 100" | bc)
  shared_memory=$(echo "$physical_memory" | awk '{print $5}')
  shared_memory_percentage=$(echo "scale=4; ($shared_memory/$total_memory) * 100" | bc)
  buff_cache_memory=$(echo "$physical_memory" | awk '{print $6}')
  buff_cache_memory_percentage=$(echo "scale=4; ($buff_cache_memory/$total_memory) * 100" | bc)
  available_memory=$(echo "$physical_memory" | awk '{print $7}')
  available_memory_percentage=$(echo "scale=4; ($available_memory/$total_memory) * 100" | bc)

  echo -e "\n=========================="
  echo -e "\033[34mPhysical general memory:\033[0m \n$physical_memory"
  echo -e "\n"
  echo -e "----------------------------"
  echo -e "\033[34mPercentages of memory usage:\033[0m"
  echo -e "----------------------------"
  # Indicates the amount of memory currently in use by processes and the operating system.
  print_stat "Used memory:        " $used_memory_percentage
  # It represents the amount of memory that is currently available and not being used at all.
  print_stat "Free memory:        " $free_memory_percentage
  # Refers to the amount of memory that is shared among several processes. 
  # This can include shared libraries or shared memory segments.
  print_stat "Shared memory:      " $shared_memory_percentage
  # Displays the amount of memory used for buffering and disk cache.
  print_stat "Buff/Cache memory:  " $buff_cache_memory_percentage
  # Indicates the amount of memory that is available to allocate to new processes or memory requests.
  # It takes into account both free and cached memory and adjusts dynamically according to the needs of the system.
  print_stat "Available memory:   " $available_memory_percentage
  echo -e "============================"

  stream_name="cpu_stats"
  memory_string="memory"

  # Convert into JSON object
  json_stats="{ 
    \"date\": \"$date_time\", 
    \"type\": \"$memory_string\", 
    \"total_memory\": \"$total_memory\", 
    \"used_memory\": \"$used_memory_percentage\", 
    \"free_memory\": \"$free_memory_percentage\", 
    \"shared_memory\": \"$shared_memory_percentage\", 
    \"buff_cache_memory\": \"$buff_cache_memory_percentage\", 
    \"available_memory\": \"$available_memory_percentage\" 
  }"
  printf '%s\n' "$json_stats"

  # Send data to kinesis
  response=$(timeout 1s aws kinesis put-record --stream-name "$stream_name" --partition-key "$date_time" --data "$json_stats" 2>&1)
  
  # Check if response contains "SequenceNumber" string
  if echo "$response" | grep -q "SequenceNumber"; then
    # Response contains "SequenceNumber" string - Ok
    echo -e "\033[32mSuccesfully data sent to AWS Kinesis\033[0m - Response: $response"
  else
    # Response doesn't contains "SequenceNumber" string - Error
    echo -e "\e[31mError at send data to AWS Kinesis\033[0m - Error: $response"
  fi


  # # Just physical memory with formats, not only in KB
  # physical_memory_in_formats=$(free -h | grep -i "mem")
  # echo -e "Physical general memory (not only in kb): \n$physical_memory_in_formats"

  # TODO: Next stats
  # usage_stats=$(vmstat -s)
  # echo -e "Usage stats: \n $usage_stats"

  # usage_memory_in_order_of_usage=$(ps aux --sort -rss)
  # echo -e "Usage memory in order of usage: \n$usage_memory_in_order_of_usage"

  sleep 1
done
