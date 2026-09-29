#!/bin/bash
# Uso: ./init_worker.sh "ens4"
IFACES=$1

# 1. Crear OVS 'br-int' si no existe
if ! sudo ovs-vsctl br-exists br-int; then
    sudo ovs-vsctl add-br br-int
fi

# 2. Conectar interfaces provistas
for iface in $IFACES; do
    if ! sudo ovs-vsctl list-ports br-int | grep -q "^${iface}$"; then
        sudo ovs-vsctl add-port br-int $iface
    fi
    sudo ip link set $iface up
done
