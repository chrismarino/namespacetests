#!/bin/bash -x

# This is a simple bridge configuration where two namespaces are connected to a bridge. 
# The bridge takes on the host IP address

# Get the local physical network info...
source ../utils/netconfig.sh

# Set the net mask for the router namespace and test namespaces
# MASK_R variable only used for routed network tests.
#MASK_R=24
MASK_NS=17

# Set the addresses for the network that the namespaces will run.
# ADDR_BRH only used for routed network tests
ADDR_NET=192.168.65.0
ADDR_NS0=192.168.65.226
ADDR_NS1=192.168.65.242
#ADDR_BRH=192.168.65.130

ADDR_VETH0=192.168.65.225
ADDR_VETH1=192.168.65.241
ADDR_LOCAL=192.168.65.129

#Namespace gateways are the veth side of the links
GW_NS0=$GW_PHY
GW_NS1=$GW_PHY
#GW_NSR=$ADDR_VETHR

# Create the namespaces
echo 'Creating the namespaces...'
ip netns add nspace0
ip netns add nspace1

# Create the vEth pairs...
echo 'Create the vEth pairs...'
ip link add ns0 type veth peer name veth0
ip link add ns1 type veth peer name veth1
echo 'Done.......'

# move the ends to the namespaces...
echo 'Move the endpoints to the namespaces...'
ip link set ns0 netns nspace0
ip link set ns1 netns nspace1
echo 'Done.......'

# Add IPs and bring up the interfaces
echo 'Add the IPs and bring up the interfaces.....'
ip netns exec nspace0 ip addr add $ADDR_NS0/$MASK_NS dev ns0
ip netns exec nspace1 ip addr add $ADDR_NS1/$MASK_NS dev ns1

ip netns exec nspace0 ip link set dev lo up
ip netns exec nspace1 ip link set dev lo up
ip netns exec nspace0 ip link set dev ns0 up
ip netns exec nspace1 ip link set dev ns1 up

ip link set dev veth0 up
ip link set dev veth1 up
#echo 'Done.......'

# Add the bridge
echo 'Adding the bridge...'
brctl addbr br0
brctl addif br0 veth0 veth1 eth0

# Bring up the brdige...
ifconfig br0 up

# Swap the IP from eth0 and br0
ip addr delete $ADDR_ETH0/$MASK_PHY dev eth0
ip addr add $ADDR_ETH0/$MASK_PHY dev br0

# And finally add the routes. 
echo 'Add the routes...'
ip netns exec nspace0 ip route add default via $GW_NS0
ip netns exec nspace1 ip route add default via $GW_NS1
ip route add default via $GW_PHY dev br0
echo 'Done.......'
