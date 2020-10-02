#!/bin/bash

#Define some colors for the command line
WARN='\033[1;31m'
SUCCESS='\033[0;32m'
INFO='\033[1;34m'
HELP='\033[1;36m'

NC='\033[0m'

blender_dir="$(dirname "$0")"

echo -e "${INFO}TopologyBlender Engaged!${NC}"

if [[ -f "$blender_dir/blender.config" ]]; then
  source "$blender_dir/blender.config"
else
  echo -e "${WARN}[FATAL ERROR]${NC} Could not find the blender.config file.\n    Please see ${INFO}blender.example.config${NC} or run ${INFO}./setup.sh${NC} before continuing."
  exit
fi

if [[ ! -f "$private_topology_path" ]]; then
  echo -e "${WARN}[FATAL ERROR]${NC} Could not locate your private topology file. Please make sure it exists."
  exit
fi

if [[ ! -f "$public_topology_path" ]]; then
  echo -e "${WARN}[FATAL ERROR]${NC} Could not locate your public topology file. Please make sure it exists."
  exit
fi

public_tmp=./tp_tmp0.json
blended=./tp_tmp1.json
merged=./tp_tmp2.json
final=./tp_tmp3.json

echo -e "Finished product will be at ${INFO}$output_topology_path${NC}"

private_peers=$(jq '.Producers | map(.valency) | add' "${private_topology_path}")
public_peers=$(jq '.Producers | map(.valency) | add' "${public_topology_path}")

total_all_peers=$(($private_peers+$public_peers))
echo -e "Found ${private_peers} private peers and ${public_peers} public peers."

if [[ ($total_all_peers -gt $max_desired_peers) ]]; then
  echo -e "${WARN}[WARNING]${NC} Total peers (${total_all_peers}) exceeds max desired peers (${max_desired_peers})!"
  echo -e "We will attempt to reduce the valency of remote peers to ${max_peer_valency}."
  jq '(.Producers[] | select(.valency > '"$max_peer_valency"') | .valency) |= '"$max_peer_valency" "${public_topology_path}" > $public_tmp
else
  jq '.' "${public_topology_path}" > $public_tmp
fi

echo -e "Flattening and grouping public and private topologies."
## We only want to flatten the public peers in the case where we have multiple nodes on the same IP in private.json
jq '.Producers=(.Producers | group_by(.addr) | map(add) | flatten)' "${public_tmp}" > $public_flat
jq -s '.[0].Producers=([.[].Producers]|flatten)|.[0]' "${private_topology_path}" "${public_flat}" > $blended
jq '.Producers=(flatten)' "${blended}" > $output_topology_path

total_peers=$(jq '.Producers | map(.valency) | add' "${output_topology_path}")

if [[ ($total_peers -gt $max_desired_peers) ]]; then
  echo -e "${WARN}[WARNING]${NC} Found ${WARN}${total_peers}${NC} peers in blended topology!"
  echo -e "Consider increasing ${HELP}max_desired_peers${NC} or decreasing ${HELP}max_valency${NC} in the config file, or fetching fewer public peers."
else
  echo -e "${SUCCESS}[OK]${NC} Found ${SUCCESS}${total_peers}${NC} peers in blended topology."
fi

rm tp_tmp*.json
