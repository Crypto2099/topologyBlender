#!/bin/bash

echo -e "Welcome to TopologyBlender!\n"

echo -e "Step #1: Please enter the (absolute) path to your private JSON topology file: "
read private_topology_path
echo -e "Step #2: Please enter the (absolute) path to your public JSON topology file: "
read public_topology_path
echo -e "Step #3: Please enter the (absolute) path to your blended JSON topology file: "
read output_topology_path
echo -e "Step #4: Please specify your max number of desired peers: [Default: 20] "
read max_desired_peers
echo -e "Step #5: Please specify your maximum peer valency: [Default: 2] "
read max_peer_valency

if [[ ($max_desired_peers < 1) ]]; then
  max_desired_peers=20
fi

if [[ ($max_peer_valency < 1) ]]; then
  max_peer_valency=2
fi

echo "#!/bin/bash

private_topology_path=\"$private_topology_path\"
public_topology_path=\"$public_topology_path\"
output_topology_path=\"$output_topology_path\"
max_desired_peers=$max_desired_peers
max_peer_valency=$max_peer_valency" > blender.config
