#!/bin/bash

# Get total cores of CPU
total_cores=$(grep -c ^processor /proc/cpuinfo)
cores=$(($total_cores - 1))


total=0
first_avg=0
dif=0
enter=true

while true; do

  # Leer los valores de los contadores de tiempo para el procesador y sus núcleos
  # read -a cpu_stats < <(grep '^cpu[0-$cores] ' /proc/stat)
  mapfile -t cpu_stats < <(cat /proc/stat | grep "^cpu[0-$cores]")
  uptime_seconds=$(awk '{print $1}' /proc/uptime)
  uptime_seconds=${uptime_seconds%.*}
  miliseconds=$(($uptime_seconds * 1000))
  cpu_stats_array_length=$(echo "${#cpu_stats[@]}")
  echo -e "$cpu_stats_array_length"
  
  for cpu in "${cpu_stats[@]}"
  do

    # Cores CPU stats
    core=$(echo $cpu | awk '{print $1}')
    just_cpu_idle_ms=$(echo $cpu | awk '{print $5}')
    usage_ms=$(echo $miliseconds - $just_cpu_idle_ms | bc)
    echo -e "Usage: $usage_ms"
    core_usage=$(echo "scale=4; ($just_cpu_idle_ms/$miliseconds) * 100" | bc )
    # echo -e "$core_usage"
    total=$(echo $total + $usage_ms | bc )
    echo -e "$total"
    
  done


  # Reset total
  if [ "$enter" = false ]; then
    avg=$(echo $total/$total_cores | bc)
    echo -e "Second Average: $avg"
    dif=$(echo $avg - $first_avg | bc)
    echo -e "Final Average: $dif"
    first_avg=0
    break
  else
    first_avg=$(echo $total/$total_cores | bc)
    echo -e "First Average: $first_avg"
    total=0
    enter=false
  fi
  sleep 1
done
