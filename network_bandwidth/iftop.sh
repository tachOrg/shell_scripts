#!/bin/bash

# visualize iftop dynamically
# sudo iftop -i wlp0s20f3 -P -o iftop_o

# iftop to output file
sudo iftop -i wlp0s20f3 -t -L 10 -B > output

