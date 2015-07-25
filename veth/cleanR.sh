echo 'Start'
ip netns delete nspace1
ip netns delete nspace0
ip netns delete nspaceR
../utils/echo0.sh
echo 'Done'
