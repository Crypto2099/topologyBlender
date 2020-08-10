# topologyBlender

##Merge and Blend Topology Files for Cardano Stake Pool Operators

To use, simply clone this repository to a location on your relay node VM.

Change the paths in the "config" file to match the location where you store your topology files.

You may need to change the permissions of the script to be executable on your system "chmod +x blend.sh".

After you have updated the "config" file you may simply run the script via "./blend.sh" to create your blended topology file.

###private_topology_path

This is the path to the topology.json file that contains your private topology

###public_topology_path

This is the path to the topology.json file that is fetched from a public source (i.e. TopologyUpdater.sh, getBuddies.sh, etc)

###output_topology_path

This is the path you would like to the completed topology.json file that can be used in your relay node for cardano-node startup

###tmp_file

This temporary file is used during script operation to combine both public and private topology files together and then flatten the results to remove (possible) duplicate entries.

This script is created and released to the community under the Creative Commons Attribution Share Alike 4.0 License (https://creativecommons.org/licenses/by-sa/4.0/). Please feel free to copy, expand, and share this script in any way you see fit so long as you follow the licensing rules.

Author: Adam Dean
Telegram: @TheRealAdamDean
My Pools: BUFFY & SPIKE
