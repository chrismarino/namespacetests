#!/bin/bash -x
GW_PHY=192.168.1.1
MASK_PHY=17
MASK_R=24
MASK_NS=28
ADDR_ETH0=192.168.0.191

ADDR_NET=192.168.65.0
ADDR_NS0=192.168.65.226
ADDR_NS1=192.168.65.242
ADDR_NSR=192.168.65.130

ADDR_VETH0=192.168.65.225
ADDR_VETH1=192.168.65.241
ADDR_VETHR=192.168.65.129

#Namespace gateways are the veth side of the links
GW_NS0=$ADDR_VETH0
GW_NS1=$ADDR_VETH1
GW_NSR=$ADDR_VETHR

# Create the namespaces
echo 'Creating the namespaces...'
ip netns add nspace0
ip netns add nspace1
ip netns add nspaceR

# Create the vEth pairs...
echo 'Create the vEth pairs...'
ip link add ns0 type veth peer name veth0
ip link add ns1 type veth peer name veth1
ip link add nsR type veth peer name vethR
echo 'Done.......'

# move the ends to the namespaces...
echo 'Move the endpoints to the namespaces...'
ip link set ns0 netns nspace0
ip link set ns1 netns nspace1
ip link set veth0 netns nspaceR
ip link set veth1 netns nspaceR
ip link set nsR netns nspaceR
echo 'Done.......'

# Add IPs and bring up the interfaces
echo 'Add the IPs and bring up the interfaces.....'
ip netns exec nspace0 ip addr add $ADDR_NS0/$MASK_NS dev ns0
ip netns exec nspace1 ip addr add $ADDR_NS1/$MASK_NS dev ns1
ip netns exec nspaceR ip addr add $ADDR_NSR/$MASK_R dev nsR

ip netns exec nspaceR ip addr add $ADDR_VETH0/$MASK_NS dev veth0
ip netns exec nspaceR ip addr add $ADDR_VETH1/$MASK_NS dev veth1
ip addr add $ADDR_VETHR/$MASK_R dev vethR

ip netns exec nspace0 ip link set dev lo up
ip netns exec nspace1 ip link set dev lo up
ip netns exec nspaceR ip link set dev lo up
ip netns exec nspace0 ip link set dev ns0 up
ip netns exec nspace1 ip link set dev ns1 up
ip netns exec nspaceR ip link set dev nsR up

ip netns exec nspaceR ip link set dev veth0 up
ip netns exec nspaceR ip link set dev veth1 up
ip link set dev vethR up
echo 'Done.......'

# Enable IP forwarding and proxy arp in the router namespace
ip netns exec nspaceR ./echo1.sh
# Enable IP forwarding and proxy arp on the VM
./echo1.sh

# And finally add the routes. 
#echo 'Add the routes...'
ip netns exec nspace0 ip route add default via $GW_NS0
ip netns exec nspace1 ip route add default via $GW_NS1
ip netns exec nspaceR ip route add default via $GW_NSR

ip route add $ADDR_NET/$MASK_R dev vethR
# this route is going to clobber the route created when vethR was added above

#echo 'Done.......'

