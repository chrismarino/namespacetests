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
MODE=bridge

# Set the addresses for the network that the namespaces will run.

ADDR_NET=192.168.65.0
ADDR_NS0=192.168.65.226
ADDR_NS1=192.168.65.227
ADDR_NS2=192.168.65.242
ADDR_NS3=192.168.65.243
#ADDR_BRH=192.168.65.130

#Namespace gateways are the veth side of the links
GW_NS0=$GW_PHY
GW_NS1=$GW_PHY
GW_NS2=$GW_PHY
GW_NS3=$GW_PHY

# Create the namespaces
echo 'Creating the namespaces...'
ip netns add nspace0
ip netns add nspace1
ip netns add nspace2
ip netns add nspace3

# Create the MACVLAN pairs...
echo 'Create the MACVLAN pairs...'
ip link add ns0 link eth0 type macvlan mode $MODE
ip link add ns1 link eth0 type macvlan mode $MODE
ip link add ns2 link eth0 type macvlan mode $MODE
ip link add ns3 link eth0 type macvlan mode $MODE

echo 'Done.......'

# move the ends to the namespaces...
echo 'Move the endpoints to the namespaces...'
ip link set ns0 netns nspace0
ip link set ns1 netns nspace1
ip link set ns2 netns nspace2
ip link set ns3 netns nspace3
echo 'Done.......'

# Add IPs and bring up the interfaces
echo 'Add the IPs and bring up the interfaces.....'
ip netns exec nspace0 ip addr add $ADDR_NS0/$MASK_NS dev ns0
ip netns exec nspace1 ip addr add $ADDR_NS1/$MASK_NS dev ns1
ip netns exec nspace2 ip addr add $ADDR_NS2/$MASK_NS dev ns2
ip netns exec nspace3 ip addr add $ADDR_NS3/$MASK_NS dev ns3

ip netns exec nspace0 ip link set dev lo up
ip netns exec nspace1 ip link set dev lo up
ip netns exec nspace2 ip link set dev lo up
ip netns exec nspace3 ip link set dev lo up

ip netns exec nspace0 ip link set dev ns0 up
ip netns exec nspace1 ip link set dev ns1 up
ip netns exec nspace2 ip link set dev ns2 up
ip netns exec nspace3 ip link set dev ns3 up

echo 'Done.......'

echo 'Add the routes to the namespace'
ip netns exec nspace0 ip route add default via $GW_NS0
ip netns exec nspace1 ip route add default via $GW_NS1
ip netns exec nspace2 ip route add default via $GW_NS2
ip netns exec nspace3 ip route add default via $GW_NS3
echo 'Done.......'

