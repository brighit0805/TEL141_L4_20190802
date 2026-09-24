#!/bin/bash
# Uso: ./routing_networks.sh <VLAN_ID_1> <VLAN_ID_2> <CIDR_1> <CIDR_2>

VLAN1=$1
VLAN2=$2
CIDR1=$3
CIDR2=$4

sudo iptables -A FORWARD -s $CIDR1 -d $CIDR2 -j ACCEPT
sudo iptables -A FORWARD -s $CIDR2 -d $CIDR1 -j ACCEPT
