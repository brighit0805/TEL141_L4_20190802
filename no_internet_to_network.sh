#!/bin/bash
# Uso: ./no_internet_to_network.sh <VLAN_ID> <CIDR>

VLAN_ID=$1
CIDR=$2

sudo iptables -t nat -D POSTROUTING -s $CIDR -o ens3 -j MASQUERADE 2>/dev/null
sudo iptables -D FORWARD -s $CIDR -i br-int -o ens3 -j ACCEPT 2>/dev/null
sudo iptables -D FORWARD -d $CIDR -i ens3 -o br-int -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null
