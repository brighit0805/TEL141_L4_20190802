#!/bin/bash
echo "=== Desplegando Actividad 1 ==="

# 1. Inicializar Nodos
ssh ubuntu@10.0.10.1 'bash -s' < ./init_worker.sh "ens4"
ssh ubuntu@10.0.10.2 'bash -s' < ./init_worker.sh "ens4"
ssh ubuntu@10.0.10.3 'bash -s' < ./init_master.sh "ens4 ens3"

# 2. Crear VLANs con DHCP en Server 3 (Master)
ssh ubuntu@10.0.10.3 'bash -s' < ./create_network_vlan.sh "100" "192.168.0.0/24" "habilitado" "192.168.0.10 192.168.0.50"
ssh ubuntu@10.0.10.3 'bash -s' < ./create_network_vlan.sh "200" "192.168.2.0/24" "habilitado" "192.168.2.10 192.168.2.50"

# 3. Salida a Internet para ambas VLANs
ssh ubuntu@10.0.10.3 'bash -s' < ./internet_to_network.sh "100" "192.168.0.0/24"
ssh ubuntu@10.0.10.3 'bash -s' < ./internet_to_network.sh "200" "192.168.2.0/24"

# 4. Desplegar VMs en Server 2
ssh ubuntu@10.0.10.2 'bash -s' < ./create_vm.sh "vm_vlan100" "br-int" "100" "1"
ssh ubuntu@10.0.10.2 'bash -s' < ./create_vm.sh "vm_vlan200" "br-int" "200" "2"
