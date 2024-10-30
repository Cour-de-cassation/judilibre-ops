#!/bin/bash
(
    echo 62.210.0.0/16 #scw-dns
    curl -s https://api.github.com/meta | jq -r '.actions[]' | grep -v '::' | tr '\n' ',' #github-actions
    curl -s https://uptimerobot.com/inc/files/ips/IPv4andIPv6.txt | grep -v '::' | tr '\n' ',' #uptime-robot
    curl -s https://updown.io/api/nodes/ipv4 | jq -r '.[]' | tr '\n' ',' #updown.io
    echo 185.24.185.46/27 #piste
    echo 185.24.186.254,185.24.186.214,185.24.187.214,185.24.184.214 #mj
    echo 51.15.223.35,174.89.249.181,91.170.21.111,51.255.99.129,51.77.234.17 #devops/piste
    echo 51.254.32.166 #devops/probe
    echo 88.180.104.201 #dev/test
    echo 80.87.224.0/22 #actimage
    echo 80.87.226.0/22 #new_actimage
    echo 80.87.225.11 #actimage_supervision
    # new_mj
    echo 143.126.250.12/32,143.126.250.13/32,143.126.250.14/32,143.126.250.15/32 # Secours 
    echo 143.126.248.12/32,143.126.248.13/32,143.126.248.14/32,143.126.248.15/32 # Secours
    echo 143.126.249.12/32,143.126.249.13/32,143.126.249.14/32,143.126.249.15/32 # Nominal
    echo 143.126.251.12/32,143.126.251.13/32,143.126.251.14/32,143.126.251.15/32 # Secours
) | tr '\n' ',' | sed 's/,$//'

# If you want to update the whitelist, update this file and deploy it by deploying judilibre-search in scaleway (with github action).
