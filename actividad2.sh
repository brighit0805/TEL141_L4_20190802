#!/bin/bash
echo "=== Desplegando Actividad 2 ==="

ssh ubuntu@10.0.10.1 'bash -s' < ./init_worker.sh "ens4"
ssh ubuntu@10.0.10.2 'bash -s' < ./init_worker.sh "ens4"
ssh ubuntu@10.0.10.3 'bash -s' < ./init_master.sh "ens4 ens3"

# Crear VLANs SIN DHCP
ssh ubuntu@10.0.10.3 'bash -s' < ./create_network_vlan.sh "100" "192.168.0.0/24" "deshabilitado"
ssh ubuntu@10.0.10.3 'bash -s' < ./create_network_vlan.sh "200" "192.168.2.0/24" "deshabilitado"

# Salida a Internet
ssh ubuntu@10.0.10.3 'bash -s' < ./internet_to_network.sh "100" "192.168.0.0/24"
ssh ubuntu@10.0.10.3 'bash -s' < ./internet_to_network.sh "200" "192.168.2.0/24"

# Desplegar VMs
ssh ubuntu@10.0.10.2 'bash -s' < ./create_vm.sh "vm_vlan100" "br-int" "100" "1"
ssh ubuntu@10.0.10.2 'bash -s' < ./create_vm.sh "vm_vlan200" "br-int" "200" "2"
