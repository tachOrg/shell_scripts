#!/bin/bash

# Functions
# Print stats of arguments passed
function print_stat() {
    local name=$1
    local usage=$2

    echo -e "\033[32m${name}\033[0m$usage"
}

# Both memories, physic general and swap
usage_memory=$(free)
echo -e "General usage memory: \n$usage_memory"

# Just physical memory
physical_memory=$(free | grep -i "mem")

total_memory=$(echo "$physical_memory" | awk '{print $2}')
used_memory=$(echo "$physical_memory" | awk '{print $3}')
used_memory_percentage=$(echo "scale=4; ($used_memory/$total_memory) * 100" | bc | sed 's/$/%/')
free_memory=$(echo "$physical_memory" | awk '{print $4}')
free_memory_percentage=$(echo "scale=4; ($free_memory/$total_memory) * 100" | bc | sed 's/$/%/')
shared_memory=$(echo "$physical_memory" | awk '{print $5}')
shared_memory_percentage=$(echo "scale=4; ($shared_memory/$total_memory) * 100" | bc | sed 's/$/%/')
buff_cache_memory=$(echo "$physical_memory" | awk '{print $6}')
buff_cache_memory_percentage=$(echo "scale=4; ($buff_cache_memory/$total_memory) * 100" | bc | sed 's/$/%/')
available_memory=$(echo "$physical_memory" | awk '{print $7}')
available_memory_percentage=$(echo "scale=4; ($available_memory/$total_memory) * 100" | bc | sed 's/$/%/')

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


# # Just physical memory with formats, not only in KB
# physical_memory_in_formats=$(free -h | grep -i "mem")
# echo -e "Physical general memory (not only in kb): \n$physical_memory_in_formats"

# TODO: Next stats
# usage_stats=$(vmstat -s)
# echo -e "Usage stats: \n $usage_stats"

# usage_memory_in_order_of_usage=$(ps aux --sort -rss)
# echo -e "Usage memory in order of usage: \n$usage_memory_in_order_of_usage"
