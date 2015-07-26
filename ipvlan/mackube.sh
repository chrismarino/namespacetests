#!/bin/bash -x

# This is a simple bridge configuration where two namespaces are connected to a bridge.
# The bridge takes on the host IP address

# Get the local physical network info...
source ../utils/netconfig.sh


# Identify the Host
INSTANCE=B

# Set the net mask for the router namespace (and bridge interface) 
# and test namespaces
# MASK_R variable only used for routed network tests.
MASK_R=24
MASK_NS=24

# Set the mode for the MAC VLAN
MODE=private

# Set the addresses for the network that the namespaces will run.
# ADDR_BRH only used for routed network tests
ADDR_NET=192.168.$PRIV_NET.0
NET_NS0=192.168.$PRIV_NET.224
NET_NS1=192.168.$PRIV_NET.240

if [ "$INSTANCE" == A ]; then
	echo 'Configuring IPs in the script for Host A'
	ADDR_NS0=192.168.$PRIV_NET.226
	ADDR_NS1=192.168.$PRIV_NET.227
	ADDR_NS2=192.168.$PRIV_NET.242
	ADDR_NS3=192.168.$PRIV_NET.243
else
	echo 'Configuring IPs in the script for Host B'
	ADDR_NS0=192.168.$PRIV_NET.228
	ADDR_NS1=192.168.$PRIV_NET.229
	ADDR_NS2=192.168.$PRIV_NET.244
	ADDR_NS3=192.168.$PRIV_NET.245
fi
echo 'Done Configureing IPs in script'
ADDR_NSR=192.168.$PRIV_NET.130
ADDR_xHOST=192.168.$PRIV_NET.1

ADDR_VETH0=192.168.$PRIV_NET.225
ADDR_VETH1=192.168.$PRIV_NET.241
ADDR_VETHR=192.168.$PRIV_NET.129

#Namespace gateways are the upstream router interface
GW_NS0=$ADDR_xHOST
GW_NS1=$ADDR_xHOST
GW_NS2=$ADDR_xHOST
GW_NS3=$ADDR_xHOST
GW_NSR=$ADDR_ETH0

# Create the namespaces
echo 'Creating the namespaces...'
ip netns add nspace0
ip netns add nspace1
ip netns add nspace2
ip netns add nspace3

# Create the MAC VLAN....
echo 'Create the MAC VLAN....'
#ip link add veth0 type veth peer name ipvl0
#ip link add nsR type veth peer name vethR

ip link add ns0 link eth0 type macvlan mode $MODE
ip link add ns1 link eth0 type macvlan mode $MODE
ip link add ns2 link eth0 type macvlan mode $MODE
ip link add ns3 link eth0 type macvlan mode $MODE
#ip link addipvl0 link eth0 nsR type macvlan mode $MODE
echo 'Done.......'

# move the ends to the namespaces...
echo 'Move the endpoints to the namespaces...'
ip link set ns0 netns nspace0
ip link set ns1 netns nspace1
ip link set ns2 netns nspace2
ip link set ns3 netns nspace3
#ip link set veth0 netns nspaceR
#ip link set nsR netns nspaceR
echo 'Done.......'

# Add IPs and bring up the interfaces
echo 'Add the IPs and bring up the interfaces.....'
ip netns exec nspace0 ip addr add $ADDR_NS0/$MASK_NS dev ns0
ip netns exec nspace1 ip addr add $ADDR_NS1/$MASK_NS dev ns1
ip netns exec nspace2 ip addr add $ADDR_NS2/$MASK_NS dev ns2
ip netns exec nspace3 ip addr add $ADDR_NS3/$MASK_NS dev ns3
#ip netns exec nspaceR ip addr add $ADDR_NSR/$MASK_PHY dev nsR

ip netns exec nspace0 ip link set dev lo up
ip netns exec nspace1 ip link set dev lo up
ip netns exec nspace2 ip link set dev lo up
ip netns exec nspace3 ip link set dev lo up
#ip netns exec nspaceR ip link set dev lo up
ip netns exec nspace0 ip link set dev ns0 up
ip netns exec nspace1 ip link set dev ns1 up
ip netns exec nspace2 ip link set dev ns2 up
ip netns exec nspace3 ip link set dev ns3 up
#ip netns exec nspaceR ip link set dev nsR up

#ip netns exec nspaceR ip link set dev veth0 up
#ip netns exec nspaceR ip link set dev veth1 up
#ip link set dev vethR up
echo 'Done.......'

# Enable IP forwarding and proxy arp in the router namespace
#ip netns exec nspaceR ../utils/echo1.sh
# Enable IP forwarding and proxy arp on the VM
#../utils/echo1.sh

# And finally add the routes. 
echo 'Add the routes...'
ip netns exec nspace0 ip route add default via $GW_NS0 dev ns0
ip netns exec nspace1 ip route add default via $GW_NS1 dev ns1
ip netns exec nspace2 ip route add default via $GW_NS2 dev ns2
ip netns exec nspace3 ip route add default via $GW_NS3 dev ns3
#ip netns exec nspace1 ip route add $ADDR_NET/$MASK_NS dev ns1
#ip netns exec nspace1 ip route add $ADDR_NET/$MASK_NS dev ns2
#ip netns exec nspace1 ip route add $ADDR_NET/$MASK_NS dev ns3
# Host routes on the router to get to them....
#ip netns exec nspaceR ip route add $ADDR_NS0 dev veth0
#ip netns exec nspaceR ip route add $ADDR_NS1 dev veth0
#ip netns exec nspaceR ip route add $ADDR_NS2 dev veth0
#ip netns exec nspaceR ip route add $ADDR_NS3 dev veth0
#ip netns exec nspaceR ip route add $ADDR_NET/$MASK_R dev veth0

# Add a route on the VM to get to the .$PRIV_NET.0/24 net
#ip route add $ADDR_NET/$MASK_R dev vethR

echo 'Done.......'
