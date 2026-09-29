#!/bin/bash
# Uso: ./routing_networks.sh <VLAN_ID_1> <VLAN_ID_2> <CIDR_1> <CIDR_2>
CIDR_1=$3
CIDR_2=$4

# Permitir tráfico bidireccional entre VLANs
sudo iptables -A FORWARD -s $CIDR_1 -d $CIDR_2 -j ACCEPT
sudo iptables -A FORWARD -s $CIDR_2 -d $CIDR_1 -j ACCEPT

