#!/bin/bash
echo "=== Desplegando Actividad 4 ==="

# Habilitar Ruteo entre VLAN 100 y VLAN 200 en Server 3
ssh ubuntu@10.0.10.3 'bash -s' < ./routing_networks.sh "100" "200" "192.168.0.0/24" "192.168.2.0/24"
