#!/bin/bash
# Uso: ./init_master.sh <interfaz1> [interfaz2 ...]

IFACES="$@"

# 1. Crear OVS local 'br-int' si no existe
sudo ovs-vsctl --may-exist add-br br-int

# 2. Conectar interfaces provistas al OVS 'br-int'
for iface in $IFACES; do
    sudo ovs-vsctl --may-exist add-port br-int $iface
done

# 3. Activar IPv4 forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# 4. Modificar acción por defecto de FORWARD a DROP
sudo iptables -P FORWARD DROP
