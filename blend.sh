#!/bin/bash
source config

#Define some colors for the command line
WARN='\033[1;31m'
SUCCESS='\033[0;32m'
INFO='\033[1;34m'
HELP='\033[1;36m'

NC='\033[0m'

blended=./tp_tmp1.json
merged=./tp_tmp2.json
final=./tp_tmp3.json

echo -e "${INFO}TopologyBlender Engaged!${NC}"
echo -e "Finished product will be at ${LTCYAN}$output_topology_path${NC}"

jq -s '.[0].Producers=([.[].Producers]|flatten)|.[0]' "${private_topology_path}" "${public_topology_path}" > $blended
jq '.Producers=(flatten | group_by(.addr) | map(add))' "${blended}" > $merged
jq '(.Producers[] | select(.valency > '"$max_peer_valency"') | .valency) |= '"$max_peer_valency" "${merged}" > $output_topology_path

total_peers=$(jq '.Producers | map(.valency) | add' "${output_topology_path}")

echo "Checking for <=$max_desired_peers peers"

if [[($total_peers > $max_desired_peers)]]; then
  echo -e "${WARN}[WARN]${NC} Found ${WARN}${total_peers}${NC} peers in blended topology!"
  echo -e "Consider increasing ${HELP}max_desired_peers${NC} or decreasing ${HELP}max_valency${NC} in the config file, or fetching fewer public peers."
else
  echo -e "${SUCCESS}[OK]${NC} Found ${SUCCESS}${total_peers}${NC} peers in blended topology."
fi

rm tp_tmp*.json
