#!/bin/bash -x

# This is a simple bridge configuration where two namespaces are connected to a bridge.
# The bridge takes on the host IP address

# Get the local physical network info...
source ../utils/netconfig.sh

# Set the net mask for the router namespace (and bridge interface) 
# and test namespaces
# MASK_R variable only used for routed network tests.
MASK_R=24
MASK_NS=28

# Set the mode for the MAV VLAN
MODE=private

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

ADDR_VETH0=192.168.65.225
ADDR_VETH1=192.168.65.241
ADDR_VETHR=192.168.65.129

#Namespace gateways are the upstream router interface
GW_NS0=$ADDR_NSR
GW_NS1=$ADDR_NSR
GW_NS2=$ADDR_NSR
GW_NS3=$ADDR_NSR
GW_NSR=$ADDR_VETHR

# Create the namespaces
echo 'Creating the namespaces...'
ip netns add nspace0
ip netns add nspace1
ip netns add nspace2
ip netns add nspace3
ip netns add nspaceR

# Create the MAC VLAN....
echo 'Create the MAC VLAN....'
ip link add veth0 type veth peer name mvl0
ip link add nsR type veth peer name vethR

ip link add ns0 link mvl0 type macvlan mode $MODE
ip link add ns1 link mvl0 type macvlan mode $MODE
ip link add ns2 link mvl0 type macvlan mode $MODE
ip link add ns3 link mvl0 type macvlan mode $MODE
ip link add nsR link mvl0 type macvlan mode $MODE
echo 'Done.......'

# move the ends to the namespaces...
echo 'Move the endpoints to the namespaces...'
ip link set ns0 netns nspace0
ip link set ns1 netns nspace1
ip link set ns2 netns nspace2
ip link set ns3 netns nspace3
ip link set veth0 netns nspaceR
ip link set nsR netns nspaceR
echo 'Done.......'

# Add IPs and bring up the interfaces
echo 'Add the IPs and bring up the interfaces.....'
ip netns exec nspace0 ip addr add $ADDR_NS0/$MASK_NS dev ns0
ip netns exec nspace1 ip addr add $ADDR_NS1/$MASK_NS dev ns1
ip netns exec nspace2 ip addr add $ADDR_NS2/$MASK_NS dev ns2
ip netns exec nspace3 ip addr add $ADDR_NS3/$MASK_NS dev ns3
ip netns exec nspaceR ip addr add $ADDR_NSR/$MASK_R dev nsR

ip addr add $ADDR_VETHR/$MASK_R dev vethR

ip netns exec nspace0 ip link set dev lo up
ip netns exec nspace1 ip link set dev lo up
ip netns exec nspace2 ip link set dev lo up
ip netns exec nspace3 ip link set dev lo up
ip netns exec nspaceR ip link set dev lo up
ip netns exec nspace0 ip link set dev ns0 up
ip netns exec nspace1 ip link set dev ns1 up
ip netns exec nspace2 ip link set dev ns2 up
ip netns exec nspace3 ip link set dev ns3 up
ip netns exec nspaceR ip link set dev nsR up

ip netns exec nspaceR ip link set dev veth0 up
#ip netns exec nspaceR ip link set dev veth1 up
ip link set dev vethR up
echo 'Done.......'

# Enable IP forwarding and proxy arp in the router namespace
ip netns exec nspaceR ../utils/echo1.sh
# Enable IP forwarding and proxy arp on the VM
../utils/echo1.sh

# And finally add the routes. 
#echo 'Add the routes...'
ip netns exec nspace0 ip route add default dev ns0
ip netns exec nspace1 ip route add default dev ns1
ip netns exec nspace2 ip route add default dev ns2
ip netns exec nspace3 ip route add default dev ns3
ip netns exec nspaceR ip route add default via $GW_NSR
# Host routes on the router to get to them....
ip netns exec nspaceR ip route add $ADDR_NS0 dev veth0
ip netns exec nspaceR ip route add $ADDR_NS1 dev veth0
ip netns exec nspaceR ip route add $ADDR_NS2 dev veth0
ip netns exec nspaceR ip route add $ADDR_NS3 dev veth0

#echo 'Done.......'


