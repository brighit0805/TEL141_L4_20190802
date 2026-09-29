#!/bin/bash
# Uso: ./internet_to_network.sh <VLAN_ID> <CIDR>
CIDR=$2

# Reglas de Masquerading e IPTables para salida a Internet
sudo iptables -t nat -A POSTROUTING -s $CIDR -o ens3 -j MASQUERADE
sudo iptables -A FORWARD -s $CIDR -i br-int -o ens3 -j ACCEPT
sudo iptables -A FORWARD -d $CIDR -i ens3 -o br-int -m state --state RELATED,ESTABLISHED -j ACCEPT
