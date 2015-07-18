echo 'Start'
ip netns delete nspace1
ip netns delete nspace0
ifconfig br0 down
brctl delbr br0
echo 'Done'
