#!/bin/bash

# Functions
# Print stats of arguments passed
function print_stat() {
    local name=$1
    local usage=$2

    echo -e "\033[32m${name}\033[0m$usage"
}

# Print a graph bar
function print_graph_bar() {
    local name=$1
    local usage=$2
    local unusage=$3

    #Print name
    printf "\033[32m${name}\033[0m"

    #Print usage
    for ((i=1; i<=usage; i++)); do
        printf "\033[34m=\033[0m"
    done

    for ((i=1; i<=unusage; i++)); do
        printf "-"
    done

    #Print break line
    printf "\n"
}

while true; do
  clear
  
  # Get current date and time
  # 'cut' property is used to extract the number of characters given in value
  miliseconds=$(date +%N | cut -b1-3)
  date_time=$(date +"%Y-%m-%d %H:%M:%S.$miliseconds")

  # Print current date
  echo "Current date & time: $date_time"

  # Get CPU usage statistics
  # With this command show each category use of CPU
  cpus=$(top -bn1 | grep '%Cpu(s)')
  max_cpu_percentage=100.0

  just_cpu_user=$(echo $cpus | awk '{print $2}' | tr ',' '.')
  cpu_user=$(echo $cpus | awk '{print $2}' | sed 's/$/%/')
  usage_cpu_user=$(echo "scale=0; (${just_cpu_user}+0.5)/1" | bc)
  unusage_cpu_user=$((100 - usage_cpu_user))

  just_cpu_system=$(echo $cpus | awk '{print $4}' | tr ',' '.')
  cpu_system=$(echo $cpus | awk '{print $4}' | sed 's/$/%/')
  usage_cpu_system=$(echo "scale=0; (${just_cpu_system}+0.5)/1" | bc)
  unusage_cpu_system=$((100 - usage_cpu_system))

  just_cpu_low_priority=$(echo $cpus | awk '{print $6}' | tr ',' '.')
  cpu_low_priority=$(echo $cpus | awk '{print $6}' | sed 's/$/%/')
  usage_cpu_low_priority=$(echo "scale=0; (${just_cpu_low_priority}+0.5)/1" | bc)
  unusage_cpu_low_priority=$((100 - usage_cpu_low_priority))

  just_cpu_idle=$(echo $cpus | awk '{print $8}' | tr ',' '.')
  cpu_idle=$(echo $cpus | awk '{print $8}' | sed 's/$/%/')
  usage_cpu_idle=$(echo "scale=0; (${just_cpu_idle}+0.5)/1" | bc)
  unusage_cpu_idle=$((100 - usage_cpu_idle))

  just_cpu_iowait=$(echo $cpus | awk '{print $10}' | tr ',' '.')
  cpu_iowait=$(echo $cpus | awk '{print $10}' | sed 's/$/%/')
  usage_cpu_iowait=$(echo "scale=0; (${just_cpu_iowait}+0.5)/1" | bc)
  unusage_cpu_iowait=$((100 - usage_cpu_iowait))

  just_cpu_hardware_i=$(echo $cpus | awk '{print $12}' | tr ',' '.')
  cpu_hardware_i=$(echo $cpus | awk '{print $12}' | sed 's/$/%/')
  usage_cpu_hardware_i=$(echo "scale=0; (${just_cpu_hardware_i}+0.5)/1" | bc)
  unusage_cpu_hardware_i=$((100 - usage_cpu_hardware_i))

  just_cpu_software_i=$(echo $cpus | awk '{print $14}' | tr ',' '.')
  cpu_software_i=$(echo $cpus | awk '{print $14}' | sed 's/$/%/')
  usage_cpu_software_i=$(echo "scale=0; (${just_cpu_software_i}+0.5)/1" | bc)
  unusage_cpu_software_i=$((100 - usage_cpu_software_i))


  just_cpu_steal=$(echo $cpus | awk '{print $16}' | tr ',' '.')
  cpu_steal=$(echo $cpus | awk '{print $16}' | sed 's/$/%/')
  usage_cpu_steal=$(echo "scale=0; (${just_cpu_steal}+0.5)/1" | bc)
  unusage_cpu_steal=$((100 - usage_cpu_steal))

  # Convert into JSON object
  json_stats="{ \"cpu_user\": \"$cpu_user\", \"cpu_sys\": \"$cpu_system\", \"cpu_niced\": \"$cpu_low_priority\", \"cpu_idle\": \"$cpu_idle\", \"cpu_iow\": \"$cpu_iowait\", \"cpu_hi\": \"$cpu_hardware_i\", \"cpu_si\": \"$cpu_software_i\", \"cpu_steal\": \"$cpu_steal\" }"
  printf '%s\n' "$json_stats"

  echo -e "\n================="
  echo "Cpu(s) percentage usage by process type: $cpus"

  echo -e "\n-----------------"
  echo -e "\033[34mStats by category\033[0m"

  echo -e "\n-----------------"
  print_stat "User CPU usage:                             " $cpu_user
  print_stat "System CPU usage:                           " $cpu_system
  print_stat "Niced processes (low priority) CPU usage:   " $cpu_low_priority
  print_stat "Inactive CPU usage:                         " $cpu_idle
  print_stat "I/O waiting CPU usage:                      " $cpu_iowait
  print_stat "Hardware interruptions CPU usage:           " $cpu_hardware_i
  print_stat "Software interruptions CPU usage:           " $cpu_software_i
  print_stat "Stolen tasks CPU usage:                     " $cpu_steal

  total_cpu=$(echo "${max_cpu_percentage} - ${just_cpu_idle}" | bc | sed 's/$/%/')

  echo -e "\033[35mCurrent total usage of CPU:\033[0m $total_cpu"
  echo -e "-----------------\n"

  print_graph_bar "User CPU usage:                        " $usage_cpu_user $unusage_cpu_user
  print_graph_bar "System CPU usage:                      " $usage_cpu_system $unusage_cpu_system
  print_graph_bar "Niced processes (low priority) usage:  " $usage_cpu_low_priority $unusage_cpu_low_priority
  print_graph_bar "Inactive CPU usage:                    " $usage_cpu_idle $unusage_cpu_idle
  print_graph_bar "I/O waiting CPU usage:                 " $usage_cpu_iowait $unusage_cpu_iowait
  print_graph_bar "Hardware interruptions CPU usage:      " $usage_cpu_hardware_i $unusage_cpu_hardware_i
  print_graph_bar "Software interruptions CPU usage:      " $usage_cpu_software_i $unusage_cpu_software_i
  print_graph_bar "Stolen tasks CPU usage:                " $usage_cpu_steal $unusage_cpu_steal
  echo -e "=================\n"

  sleep 1
done


# sum=$(top -bn1 | grep "Cpu(s)" | awk -v n=$(nproc) '{sum=0; for(i=2;i<=n+1;i++){sum+=$i}; printf "%.2f%%\n", sum}')
# just_one_register_top_with_active_process=$(top -ibn1)

# # 1 3 - 3 segundos
# percentage=$(vmstat 1 3 | tail -1 | awk '{printf 100 - $15"%\n"}')

cpus2=$(top -bn1 | awk '/Cpu/')
# Si se toma este %Cpu(s) en el id (idle) y se le resta a 100 se obtiene el valor de test2
only_top=$(top -n 1)
test2=$(top -bn1 | awk '/Cpu/ { print $2}')c


# echo "Load value: $only_load"
# echo "CPU Usage: $cpu"
# echo "CPUs: $cpus"
# echo "Sum: $sum"
# echo "Percentage: $percentage"
# echo "One top register: $just_one_register_top_with_active_process"
# echo "//////////////////////////////"
# echo "//////////////////////////////"
# echo "Test 1: $only_top"
# echo "CPUs 2: $cpus2"
# echo "Test 2: $test2"
