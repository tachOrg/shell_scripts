#!/bin/bash

# TODO: Fix it - Almost done
# Get total cores of CPU
total_cores=$(grep -c ^processor /proc/cpuinfo)
cores=$(($total_cores - 1))


first_avg=0
second_avg=0
dif_avg=0
first_ms=0
dif_ms=0
enter=true
one_sec_in_ms=1000

while true; do

  cpu_usage_total=0
  # Leer los valores de los contadores de tiempo para el procesador y sus núcleos
  # read -a cpu_stats < <(grep '^cpu[0-$cores] ' /proc/stat)
  mapfile -t cpu_stats < <(cat /proc/stat | grep "^cpu[0-$cores]")
  uptime_seconds=$(awk '{print $1}' /proc/uptime)
  uptime_seconds=${uptime_seconds%.*}
  miliseconds=$(($uptime_seconds * 1000))
  echo -e "Miliseconds: $miliseconds"
  cpu_stats_array_length=$(echo "${#cpu_stats[@]}")
  echo -e "$cpu_stats[@]"
  echo -e "$cpu_stats_array_length"
  
  for cpu in "${cpu_stats[@]}"
  do

    # Cores CPU stats
    core=$(echo $cpu | awk '{print $1}')
    just_cpu_idle_ms=$(echo $cpu | awk '{print $5}')
    usage_ms=$(echo $miliseconds - $just_cpu_idle_ms | bc)
    core_usage=$(echo "scale=4; ($just_cpu_idle_ms/$miliseconds) * 100" | bc )
    # echo -e "$core_usage"
    cpu_usage_total=$(echo $cpu_usage_total + $usage_ms | bc )
    
  done

  echo -e "Idle usage: $cpu_usage_total"

  # Reset CPU usage total
  if [ "$enter" = false ]; then
    second_avg=$(echo $cpu_usage_total/$total_cores | bc)
    echo -e "Second Average: $second_avg"
    dif_avg=$(echo $second_avg - $first_avg | bc)
    echo -e "Final Average: $dif_avg"
    dif_ms=$(echo $miliseconds - $first_ms | bc)
    echo -e "Final ms: $dif_ms"
    avg_core_usage=$(echo "scale=4; (($dif_ms-$dif_avg)/$one_sec_in_ms) * 100" | bc )
    echo -e "\033[32mLast second CPU usage:\033[0m $avg_core_usage"

    first_avg=0
    dif_avg=0
    first_ms=0
    enter=true
    # break
  else
    first_avg=$(echo $cpu_usage_total/$total_cores | bc)
    echo -e "First Average: $first_avg"
    first_ms=$miliseconds
    echo -e "First Ms: $first_avg"
    second_avg=0
    dif_ms=0
    cpu_usage_total=0
    enter=false
  fi
  sleep 1
done
