#!/bin/bash -x
GW_PHY=192.168.1.1
MASK=/25
ADDR_NS0=192.168.65.226
ADDR_NS1=192.168.65.242
ADDR_ETH0=192.168.0.191
ADDR_VETH0=192.168.65.225
ADDR_VETH1=192.168.65.241
ADDR_BR0=192.168.65.2
ADDR_NULL=0.0.0.0

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
ip addr add $ADDR_VETH0$MASK dev veth0
ip addr add $ADDR_VETH1$MASK dev veth1
ip netns exec nspace0 ip addr add $ADDR_NS0$MASK dev ns0
ip netns exec nspace1 ip addr add $ADDR_NS1$MASK dev ns1

ip netns exec nspace0 ip link set dev lo up
ip netns exec nspace1 ip link set dev lo up
ip netns exec nspace0 ip link set dev ns0 up
ip netns exec nspace1 ip link set dev ns1 up

ip link set dev veth0 up
ip link set dev veth1 up
echo 'Done.......'

# Add the bridge.
echo 'Add the bridge...'
brctl addbr br0
brctl addif br0 eth0 veth0 veth1

#Move the IP to the bridge
ip addr delete $ADDR_ETH0$MASK dev eth0
ip addr add $ADDR_ETH0$MASK dev br0
ip addr add $ADDR_NULL$MASK dev eth0

#bring up the brdige...
echo 'Bring up the bridge.......'
ifconfig br0 up

# And finall add the routes. Not adding default routes becase something is 
#messed up with the routeing table when the df is set.
#echo 'Add the routes...'
ip netns exec nspace0 ip route add $GW_PHY$MASK dev ns0
ip netns exec nspace1 ip route add $GW_PHY$MASK dev ns1
ip route add default $GW_PHY$MASK dev br0

#echo 'Done.......'


