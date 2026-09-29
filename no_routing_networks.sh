#!/bin/bash
# Uso: ./no_routing_networks.sh <VLAN_ID_1> <VLAN_ID_2> <CIDR_1> <CIDR_2>
CIDR_1=$3
CIDR_2=$4

# Eliminar enrutamiento inter-VLAN
sudo iptables -D FORWARD -s $CIDR_1 -d $CIDR_2 -j ACCEPT 2>/dev/null || true
sudo iptables -D FORWARD -s $CIDR_2 -d $CIDR_1 -j ACCEPT 2>/dev/null || true
