#!/bin/bash
# Uso: ./init_worker.sh <interfaz1> [interfaz2 ...]

IFACES="$@"

sudo ovs-vsctl --may-exist add-br br-int
for iface in $IFACES; do
    sudo ovs-vsctl --may-exist add-port br-int $iface
done
