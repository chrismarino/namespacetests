#!/bin/bash -x

echo 0 > /proc/sys/net/ipv4/conf/all/proxy_arp
echo 0 > /proc/sys/net/ipv4/ip_forward
