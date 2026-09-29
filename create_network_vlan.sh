#!/bin/bash
# Uso: ./create_network_vlan.sh <VLAN_ID> <CIDR> <habilitado|deshabilitado> [RANGO_DHCP]
VLAN_ID=$1
CIDR=$2
DHCP_OPTION=$3
DHCP_RANGE=$4

# 1. Modificar FORWARD de ACCEPT a DROP
sudo iptables -P FORWARD DROP

# 2. Crear interfaz interna OVS para Gateway
GW_PORT="gw_vlan${VLAN_ID}"
GW_IP=$(echo $CIDR | sed 's/\.0\/24/\.1\/24/')

if ! sudo ovs-vsctl list-ports br-int | grep -q "^${GW_PORT}$"; then
    sudo ovs-vsctl add-port br-int $GW_PORT -- set Interface $GW_PORT type=internal tag=$VLAN_ID
fi

sudo ip addr flush dev $GW_PORT
sudo ip addr add $GW_IP dev $GW_PORT
sudo ip link set $GW_PORT up

# 3. Configurar DHCP en Linux Network Namespace si está habilitado
if [ "$DHCP_OPTION" == "habilitado" ]; then
    NS_NAME="ns_dhcp_vlan${VLAN_ID}"
    VETH_OVS="veth_dhcp${VLAN_ID}"
    VETH_NS="veth_ns${VLAN_ID}"
    DHCP_IP=$(echo $CIDR | sed 's/\.0\/24/\.2\/24/')
    GW_ONLY_IP=$(echo $GW_IP | cut -d'/' -f1)

    sudo ip netns add $NS_NAME 2>/dev/null || true
    sudo ip link add $VETH_OVS type veth peer name $VETH_NS 2>/dev/null || true

    sudo ovs-vsctl add-port br-int $VETH_OVS tag=$VLAN_ID 2>/dev/null || true
    sudo ip link set $VETH_NS netns $NS_NAME

    sudo ip link set $VETH_OVS up
    sudo ip netns exec $NS_NAME ip addr add $DHCP_IP dev $VETH_NS
    sudo ip netns exec $NS_NAME ip link set $VETH_NS up
    sudo ip netns exec $NS_NAME ip link set lo up

    # Iniciar dnsmasq dentro del namespace
    sudo ip netns exec $NS_NAME dnsmasq \
        --interface=$VETH_NS \
        --dhcp-range=$(echo $DHCP_RANGE | cut -d' ' -f1),$(echo $DHCP_RANGE | cut -d' ' -f2),255.255.255.0 \
        --dhcp-option=3,$GW_ONLY_IP \
        --dhcp-option=6,8.8.8.8
fi
