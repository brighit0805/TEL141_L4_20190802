#!/bin/bash
# Uso: ./no_routing_networks.sh <VLAN_ID_1> <VLAN_ID_2> <CIDR_1> <CIDR_2>

VLAN1=$1
VLAN2=$2
CIDR1=$3
CIDR2=$4

sudo iptables -D FORWARD -s $CIDR1 -d $CIDR2 -j ACCEPT 2>/dev/null
sudo iptables -D FORWARD -s $CIDR2 -d $CIDR1 -j ACCEPT 2>/dev/null
