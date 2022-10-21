#!/bin/bash
(
    echo 62.210.0.0/16 #scw-dns
    curl -s https://api.github.com/meta | jq -r '.actions[]' | grep -v '::' | tr '\n' ',' #github-actions
    curl -s https://uptimerobot.com/inc/files/ips/IPv4andIPv6.txt | grep -v '::' | tr '\n' ',' #uptime-robot
    curl -s https://updown.io/api/nodes/ipv4 | jq -r '.[]' | tr '\n' ',' #updown.io
    echo 185.24.185.46/27 #piste
    echo 185.24.186.214,185.24.187.214 #mj
    echo 51.15.223.35,174.89.249.181,91.170.21.111 #devops
    echo 80.87.224.0/22 #actimage
    echo 80.87.226.0/22 #new_actimage
) | tr '\n' ',' | sed 's/,$//'
