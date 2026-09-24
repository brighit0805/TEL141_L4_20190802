#!/bin/bash
# Uso: ./create_network_vlan.sh <VLAN_ID> <CIDR> <DHCP_ENABLED 1|0> [DHCP_START] [DHCP_END]

VLAN_ID=$1
CIDR=$2
DHCP_ENABLE=$3
DHCP_START=$4
DHCP_END=$5

# Obtener la primera IP util para usarla como Gateway
GW_IP=$(echo $CIDR | cut -d'/' -f1 | awk -F. '{print $1"."$2"."$3"."$4+1}')
PREFIX=$(echo $CIDR | cut -d'/' -f2)

# 1. Crear interfaz interna en OVS con el VLAN ID
INT_NAME="gw_vlan${VLAN_ID}"
sudo ovs-vsctl --may-exist add-port br-int $INT_NAME -- set Interface $INT_NAME type=internal tag=$VLAN_ID
sudo ip addr flush dev $INT_NAME
sudo ip addr add ${GW_IP}/${PREFIX} dev $INT_NAME
sudo ip link set $INT_NAME up

# 2. Configurar DHCP si esta habilitado
if [ "$DHCP_ENABLE" -eq 1 ]; then
    NS_NAME="dhcp_vlan${VLAN_ID}"
    VETH_OVS="veth_dhcp${VLAN_ID}"
    VETH_NS="veth_ns${VLAN_ID}"
    DHCP_IP=$(echo $CIDR | cut -d'/' -f1 | awk -F. '{print $1"."$2"."$3"."$4+2}')

    # Crear Namespace y VETH pair
    sudo ip netns add $NS_NAME
    sudo ip link add $VETH_OVS type veth peer name $VETH_NS
    sudo ovs-vsctl --may-exist add-port br-int $VETH_OVS tag=$VLAN_ID
    sudo ip link set $VETH_OVS up

    # Mover la interfaz al Namespace y configurar IP
    sudo ip link set $VETH_NS netns $NS_NAME
    sudo ip netns exec $NS_NAME ip addr add ${DHCP_IP}/${PREFIX} dev $VETH_NS
    sudo ip netns exec $NS_NAME ip link set $VETH_NS up
    sudo ip netns exec $NS_NAME ip link set lo up
    sudo ip netns exec $NS_NAME ip route add default via $GW_IP

    # Levantar servicio Dnsmasq dentro del Namespace
    sudo ip netns exec $NS_NAME dnsmasq \
      --interface=$VETH_NS \
      --dhcp-range=${DHCP_START},${DHCP_END},255.255.255.0 \
      --dhcp-option=3,${GW_IP} \
      --dhcp-option=6,8.8.8.8
fi
