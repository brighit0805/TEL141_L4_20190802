#!/bin/bash
echo "=== Desplegando Actividad 1 ==="

# 1. Inicializar Nodos
ssh ubuntu@10.0.10.1 'bash -s' < ./init_worker.sh "ens4"
ssh ubuntu@10.0.10.2 'bash -s' < ./init_worker.sh "ens4"
ssh ubuntu@10.0.10.3 'bash -s' < ./init_master.sh "ens4 ens3"

# 2. Crear red VLAN 100 SIN DHCP en Server 3 (Master)
ssh ubuntu@10.0.10.3 'bash -s' < ./create_network_vlan.sh "100" "192.168.0.0/24" "deshabilitado"

# 3. Salida a Internet para VLAN 100
ssh ubuntu@10.0.10.3 'bash -s' < ./internet_to_network.sh "100" "192.168.0.0/24"

# 4. Crear Contenedor/Namespace cliente en Server 1
ssh ubuntu@10.0.10.1 '
  sudo ip netns add ns_vlan100 2>/dev/null || true
  sudo ip link add veth_vlan100 type veth peer name veth_host100 2>/dev/null || true
  sudo ip link set veth_vlan100 netns ns_vlan100 2>/dev/null || true
  sudo ovs-vsctl add-port br-int veth_host100 tag=100 2>/dev/null || true
  sudo ip link set veth_host100 up
  sudo ip netns exec ns_vlan100 ip addr flush dev veth_vlan100
  sudo ip netns exec ns_vlan100 ip addr add 192.168.0.10/24 dev veth_vlan100
  sudo ip netns exec ns_vlan100 ip link set veth_vlan100 up
  sudo ip netns exec ns_vlan100 ip link set lo up
  sudo ip netns exec ns_vlan100 ip route add default via 192.168.0.1 2>/dev/null || true
'

# 5. Desplegar Máquina Virtual en Server 2
ssh ubuntu@10.0.10.2 'bash -s' < ./create_vm.sh "vm_vlan100" "br-int" "100" "1"
