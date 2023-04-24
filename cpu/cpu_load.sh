#!/bin/bash

# Load command
load=$(top -bn1 | grep load)

# Total cores in CPU
total_cores=$(grep -c ^processor /proc/cpuinfo)

# Values by minutes
# Just in the first two results apply 'sed' option, because is necessary delete the last '.' character
one_minute_load=$(echo "$load" | awk '{print $10}' | tr ',' '.' | sed 's/.$//')
one_minute_load_percentage=$(echo "scale=0; (${one_minute_load}*100)" | bc | sed 's/$/%/')
one_minute_average_by_core=$(echo "scale=0; (((${one_minute_load}*100)/${total_cores})+0.5)/1" | bc | sed 's/$/%/')

five_minute_load=$(echo "$load" | awk '{print $11}' | tr ',' '.' | sed 's/.$//')
five_minute_load_percentage=$(echo "scale=0; (${five_minute_load}*100)" | bc | sed 's/$/%/')
five_minute_average_by_core=$(echo "scale=0; (((${five_minute_load}*100)/${total_cores})+0.5)/1" | bc | sed 's/$/%/')

fifteen_minute_load=$(echo "$load" | awk '{print $12}' | tr ',' '.')
fifteen_minute_load_percentage=$(echo "scale=0; (${fifteen_minute_load}*100)" | bc | sed 's/$/%/')
fifteen_minute_average_by_core=$(echo "scale=0; (((${fifteen_minute_load}*100)/${total_cores})+0.5)/1" | bc | sed 's/$/%/')


# Print results
echo -e "\n================="
echo -e "\033[34mAverage CPU Load by periods\033[0m"

echo -e "\n-----------------"
echo -e "\033[32mAverage CPU load in last 1 minute:\033[0m ------------- $one_minute_load_percentage"
echo -e "\033[32mAverage CPU load in last 1 minute\033[0m \033[35mby core:\033[0m ----- $one_minute_average_by_core"
echo -e "\n"

echo -e "\033[32mAverage CPU load in last 5 minutes:\033[0m ------------ $five_minute_load_percentage"
echo -e "\033[32mAverage CPU load in last 5 minutes\033[0m \033[35mby core:\033[0m ---- $five_minute_average_by_core"
echo -e "\n"

echo -e "\033[32mAverage CPU load in last 15 minutes:\033[0m ------------ $fifteen_minute_load_percentage"
echo -e "\033[32mAverage CPU load in last 15 minutes\033[0m \033[35mby core:\033[0m --- $fifteen_minute_average_by_core"
echo -e "\n-----------------"
echo -e "\n"
echo -e "=================\n"
