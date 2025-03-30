#!/bin/bash

# get_my_ip.sh
IP=$(curl -s https://checkip.amazonaws.com)

# Return the result in JSON format.
echo "{\"ip\": \"${IP}/32\"}"
