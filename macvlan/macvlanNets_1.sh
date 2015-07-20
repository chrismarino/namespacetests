#!/bin/bash -x

# This is a simple bridge configuration where two namespaces are connected to a bridge.
# The bridge takes on the host IP address

# Get the local physical network info...
source ../netconfig.sh

# Set the net mask for the router namespace and test namespaces
# MASK_R variable only used for routed network tests.
#MASK_R=24
MASK_NS=17

# Set the mode of the MACVLAN
MODE=private

# Set the addresses for the network that the namespaces will run.
# ADDR_BRH only used for routed network tests

ADDR_NET=192.168.65.0
ADDR_NS0=192.168.65.226
ADDR_NS2=192.168.65.242
#ADDR_BRH=192.168.65.130

#ADDR_VETH0=192.168.65.225
#ADDR_VETH1=192.168.65.241

#Namespace gateways are the veth side of the links
GW_NS0=$GW_PHY
GW_NS2=$GW_PHY
#GW_NSR=$ADDR_VETHR

# Create the namespaces
echo 'Creating the namespaces...'
ip netns add nspace0
ip netns add nspace2

# Create the MACVLAN pairs...
echo 'Create the MACVLAN pairs...'
ip link add ns0 link eth0 type macvlan mode $MODE
ip link add ns2 link eth0 type macvlan mode $MODE

echo 'Done.......'

# move the ends to the namespaces...
echo 'Move the endpoints to the namespaces...'
ip link set ns0 netns nspace0
ip link set ns2 netns nspace2
echo 'Done.......'

# Add IPs and bring up the interfaces
echo 'Add the IPs and bring up the interfaces.....'
ip netns exec nspace0 ip addr add $ADDR_NS0/$MASK_NS dev ns0
ip netns exec nspace2 ip addr add $ADDR_NS2/$MASK_NS dev ns2

ip netns exec nspace0 ip link set dev lo up
ip netns exec nspace2 ip link set dev lo up
ip netns exec nspace0 ip link set dev ns0 up
ip netns exec nspace2 ip link set dev ns2 up

#echo 'Done.......'

# And finally add the routes. 
#echo 'Add the routes...'
ip netns exec nspace0 ip route add default via $GW_NS0
ip netns exec nspace2 ip route add default via $GW_NS2

#echo 'Done.......'


