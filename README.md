# topologyBlender

## Merge and Blend Topology Files for Cardano Stake Pool Operators

To use, simply clone this repository to a location on your relay node machine.

You may need to change the permission of the scripts in this directory to be executable on your system 

```
chmod +x blend.sh
chmod +x setup.sh
```
As of this version you can now use the included *setup.sh* to create the **blender.config** file needed for operation.

If you would prefer to create your **blender.config** file on your own, you may use the included *blender.example.config* as an example.

Change the paths in the "config" file to match the location where you store your topology files.

After you have updated the "config" file you may simply run the script via "./blend.sh" to create your blended topology file.

## Configuration Options

#### private_topology_path *(absolute path)*

This is the path to the topology.json file that contains your private topology

#### public_topology_path *(absolute path)*

This is the path to the topology.json file that is fetched from a public source (i.e. TopologyUpdater.sh, getBuddies.sh, etc)

#### output_topology_path *(absolute path)*

This is the path you would like to the completed topology.json file that can be used in your relay node for cardano-node startup

#### max_desired_peers *(integer)*

This should be set to the maximum number of peers you would like in your topology. The blender will not place a hard limit on this but will warn you if your combined topology includes more than this number of peers.

#### max_peer_valency *(integer)*

If the combination of your private topology and public topology total more than **max_desired_peers** the script will attempt to reduce the number of remote peers by reducing valency in **public** relays to this specified maximum.

## License

This script is created and released to the community under the Creative Commons Attribution Share Alike 4.0 License (https://creativecommons.org/licenses/by-sa/4.0/). Please feel free to copy, expand, and share this script in any way you see fit so long as you follow the licensing rules.

### Author

**Author:** Adam Dean (Crypto2099, Corp) https://crypto2099.io

**Telegram:** @TheRealAdamDean

**My Pools:** BUFFY & SPIKE

## Thanks

All of my thanks go out to the fantastic Cardano SPO community for their constant inspiration, help, feedback, and support.

We're all in this together!

Also a special thanks to our QA team, who have chosen to remain anonymous but without whom this wouldn't be possible!
