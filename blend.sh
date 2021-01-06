#!/bin/bash

#Define some colors for the command line
WARN='\033[1;31m'
REKT='\033[1;31m'
SUCCESS='\033[0;32m'
INFO='\033[1;34m'
HELP='\033[1;36m'

NC='\033[0m'

blender_dir="$(dirname "$0")"

echo -e "${INFO}TopologyBlender Engaged!${NC}"


if [[ -f "$blender_dir/blender.config" ]]; then
  source "$blender_dir/blender.config"
else
  echo -e "${WARN}[FATAL ERROR]${NC} Could not find the blender.config file.\n Please see ${INFO}blender.example.config${NC} or run ${INFO}./setup.sh${NC} before continuing."
  exit
fi

if [[ ! -f "$private_topology_path" ]]; then
  echo -e "${WARN}[FATAL ERROR]${NC} Could not locate your private topology file.\n Please make sure it exists."
  exit
fi

if [[ ! -f "$public_topology_path" ]]; then
  echo -e "${WARN}[FATAL ERROR]${NC} Could not locate your public topology file.\n Please make sure it exists."
  exit
fi

echo -e "+===================================================================+"
echo -e "|  ${HELP}TopologyBlender${NC} by ${INFO}Adam Dean${NC} | ${HELP}Crypto2099, Corp.${NC} | Pool: ${SUCCESS}BUFFY${NC}   |"
echo -e "+===================================================================+"

public_topology=$(jq . $public_topology_path)
private_topology=$(jq . $private_topology_path)

private_peers=$(jq '.Producers | map(.valency) | add' <<< $private_topology)
public_peers=$(jq '.Producers | map(.valency) | add' <<< $public_topology)
total_all_peers=$(($private_peers+$public_peers))
echo -e " Found ${SUCCESS}${private_peers}${NC} private peers and ${HELP}${public_peers}${NC} public peers."

cncli_path=$(command -v cncli)

if [[ -z "$cncli_path" ]]; then
  echo -e " ${REKT}CNCLI was not detected, cannot check topologies!${NC}"
else
  echo -e " ${INFO}CNCLI Detected!${NC}"
  echo -e " ${INFO}Checking private topology...${NC}"
  echo -e "    We will alert you about private peers that are unreachable but\n    will not remove them from the topology."
  private_topology=$(jq -c '.Producers[]' <<< $private_topology | while read i; do
    host=$(jq -r '.addr' <<< $i)
    port=$(jq -r '.port' <<< $i)
    j=$($cncli_path ping --host ${host} --port ${port})
    status=$(jq -r '.status' <<< $j)
    if [[ $status == 'ok' ]]; then
      echo $i
    else
      echo -e "   ${REKT}Private Peer REKT!!! Host: ${host} Port: ${port}" 1>&2
      echo $i
    fi
  done | jq -sr 'unique_by(.addr) | flatten | {Producers: .}')
  echo -e " ${INFO}Checking public topology...${NC}"
  public_topology=$(jq -c '.Producers[]' <<< $public_topology | while read i; do
    host=$(jq -r '.addr' <<< $i)
    port=$(jq -r '.port' <<< $i)
    j=$($cncli_path ping --host ${host} --port ${port})
    status=$(jq -r '.status' <<< $j)
    if [[ $status == 'ok' ]]; then
      connectDuration=$(jq -r '.connectDurationMs' <<< $j)
      durationMs=$(jq -r '.durationMs' <<< $j)
      echo -e "   ${SUCCESS}Good Peer!${NC} Host: ${host} ConnectDurationMs: ${connectDuration} DurationMs: ${durationMs}" 1>&2
      i=$(jq ". + {connectDurationMs: $connectDuration, durationMs: $durationMs}" <<< $i)
      echo $i
    else
      echo -e "   ${REKT}REKT Peer!${NC} Host: ${host} Port: ${port} Status: ${status}" 1>&2
    fi
  done | jq -sr 'unique_by(.addr) | sort_by(.durationMs) | flatten | {Producers: .}')
fi

net_peer_count=$(jq '.Producers | map(.valency) | add' <<< $public_topology)

rekt_peers=$((public_peers-net_peer_count))

if [[ rekt_peers -gt 0 ]]; then
  echo -e " ${REKT}Found ${rekt_peers} rekt peers!${NC}"
fi

total_all_peers=$(($private_peers+$net_peer_count))

if [[ $total_all_peers -gt $max_desired_peers ]]; then
  echo -e " ${WARN}[WARNING]${NC} Total peers (${total_all_peers}) exceeds max desired peers (${max_desired_peers})!"
  echo -e "    We will attempt to reduce the valency of remote peers to ${max_peer_valency}."
  public_topology=$(jq '(.Producers[] | select(.valency > '"$max_peer_valency"') | .valency) |= '"$max_peer_valency" <<< $public_topology)
fi

net_peer_count=$(jq '.Producers | map(.valency) | add' <<< $public_topology)

total_all_peers=$(($private_peers+$net_peer_count))

if [[ $total_all_peers -gt $max_desired_peers ]]; then
  echo -e " ${WARN}[WARNING]${NC} Total peer count (${total_all_peers}) still exceeds max desired peers (${max_desired_peers})!"
  echo -e "    We will slice the public peers to meet desired peer count."
  public_needed=$(($max_desired_peers-$private_peers))
  public_topology=$(jq "{Producers: .Producers[:$public_needed]}" <<< $public_topology)
fi

echo -e " ${INFO}Flattening and grouping public and private topologies.${NC}"
blended="$private_topology$public_topology"
blended=$(jq -s '.[0].Producers=([.[].Producers]|flatten)|.[0]' <<< $blended)
jq '.Producers=(flatten | group_by(.addr) | map(add))' <<< $blended > $output_topology_path

total_peers=$(jq '.Producers | map(.valency) | add' "${output_topology_path}")

if [[ ($total_peers -gt $max_desired_peers) ]]; then
  echo -e " ${WARN}[WARNING]${NC} Found ${WARN}${total_peers}${NC} peers in blended topology!"
  echo -e "    Consider increasing ${HELP}max_desired_peers${NC} or decreasing ${HELP}max_valency${NC} in the config file, or fetching fewer public peers."
else
  echo -e " ${SUCCESS}[DONE]${NC} Found ${SUCCESS}${total_peers}${NC} peers in blended topology."
  echo -e "    Finished topology file is located at:\n    ${INFO}$output_topology_path${NC}"
fi

# rm tp_tmp*.json
