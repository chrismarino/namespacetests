#!/bin/bash -x

# This is a simple bridge configuration where two namespaces are connected to a bridge.
# The bridge takes on the host IP address

# Get the local physical network info...
source ../utils/netconfig.sh

# Set the net mask for the router namespace (and bridge interface) 
# and test namespaces
# MASK_R variable only used for routed network tests.
MASK_R=24
MASK_NS=24

# Set the mode for the IP VLAN
MODE=l3

# Set the addresses for the network that the namespaces will run.
# ADDR_BRH only used for routed network tests
ADDR_NET=192.168.65.0
NET_NS0=192.168.65.224
NET_NS1=192.168.65.240
ADDR_NS0=192.168.65.226
ADDR_NS1=192.168.65.227
ADDR_NS2=192.168.65.242
ADDR_NS3=192.168.65.243
ADDR_NSR=192.168.65.130
ADDR_xHOST=192.168.0.198

ADDR_VETH0=192.168.65.225
ADDR_VETH1=192.168.65.241
ADDR_VETHR=192.168.65.129

#Namespace gateways are the upstream router interface
GW_NS0=$ADDR_xHOST
GW_NS1=$ADDR_xHOST
GW_NS2=$ADDR_xHOST
GW_NS3=$ADDR_xHOST
GW_NSR=$ADDR_ETH0

# Enable IP forwarding and proxy arp on the VM
#../utils/echo1.sh

# And finally add the routes. 

# Add a route on the VM to get to the .65.0/24 net
ip route add $ADDR_NET/$MASK_R vi 192.168.0.110 dev eth0

echo 'Done.......'
