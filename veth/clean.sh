echo 'Start'
echo '1'
ip netns delete nspace1
echo '2'
ip netns delete nspace0
echo '3'
ip netns delete nspaceR
echo '4'
ifconfig br0 down
echo '6'
brctl delbr br0
echo 'Done'
