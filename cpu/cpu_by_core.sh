#!/bin/bash

usa=$(grep -w 'cpu' /proc/stat | awk '{usage=($2+$3+$4)*100/($2+$3+$4+$5+$6+$7+$8)} END {print usage"%"}')

echo "$usa"