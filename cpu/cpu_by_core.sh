#!/bin/bash

total_cores=$(grep -c ^processor /proc/cpuinfo)
cores=$(($total_cores - 1))

# cpus=$(cat /proc/stat | grep "^cpu[0-$cores]")
mapfile -t cpus < <(cat /proc/stat | grep "^cpu[0-$cores]")
uptime_seconds=$(awk '{print $1}' /proc/uptime)
uptime_seconds=${uptime_seconds%.*}
miliseconds=$(($uptime_seconds * 1000))
echo -e "Miliseconds: $miliseconds"

for cpu in "${cpus[@]}"
do
  just_cpu_idle_ms=$(echo $cpu | awk '{print $5}')
  cpu_usage=$(echo "scale=4; $just_cpu_idle_ms/$miliseconds" | bc )
  echo -e "$cpu_usage"
  echo "$cpu"
done
