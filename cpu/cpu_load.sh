#!/bin/bash

# Load command
load=$(top -bn1 | grep load)
echo -e "$load"

# Total cores in CPU
total_cores=$(grep -c ^processor /proc/cpuinfo)

# Ask for minutes load
minutes=$(echo "$load" | awk '{print $6}')
echo -e "Mins: $minutes"
min_comparative="min"

# Values by minutes
if [ "$minutes" = "$min_comparative" ]; then
  echo -e "Entré al if"
  one_minute_load=$(echo "$load" | awk '{print $11}' | tr ',' '.' | sed 's/.$//')
  one_minute_load_and_cores=$(echo "$one_minute_load"/"$total_cores cores")

  five_minutes_load=$(echo "$load" | awk '{print $12}' | tr ',' '.' | sed 's/.$//')
  five_minutes_load_and_cores=$(echo "$five_minutes_load"/"$total_cores cores")

  fifteen_minutes_load=$(echo "$load" | awk '{print $13}' | tr ',' '.' | sed 's/.$//')
  fifteen_minutes_load_and_cores=$(echo "$fifteen_minutes_load"/"$total_cores cores")
else
  echo -e "Entré al else"
  one_minute_load=$(echo "$load" | awk '{print $10}' | tr ',' '.' | sed 's/.$//')
  one_minute_load_and_cores=$(echo "$one_minute_load"/"$total_cores cores")

  five_minutes_load=$(echo "$load" | awk '{print $11}' | tr ',' '.' | sed 's/.$//')
  five_minutes_load_and_cores=$(echo "$five_minutes_load"/"$total_cores cores")

  fifteen_minutes_load=$(echo "$load" | awk '{print $12}' | tr ',' '.' | sed 's/.$//')
  fifteen_minutes_load_and_cores=$(echo "$fifteen_minutes_load"/"$total_cores cores")
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
