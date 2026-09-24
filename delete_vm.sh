#!/bin/bash
# Uso: ./delete_vm.sh <NOMBRE_VM> <NOMBRE_OVS> <VLAN_ID> <PUERTO_VNC>

VM_NAME=$1
BASE_DIR="/var/lib/libvirt/images"
BASE_IMG="${BASE_DIR}/ubuntu-base.qcow2"
VM_DISK="${BASE_DIR}/${VM_NAME}.qcow2"

sudo virsh destroy $VM_NAME 2>/dev/null
sudo virsh undefine $VM_NAME 2>/dev/null
sudo rm -f $VM_DISK

DELTAS=$(grep -l "$BASE_IMG" ${BASE_DIR}/*.qcow2 2>/dev/null | wc -l)
if [ "$DELTAS" -eq 0 ]; then
    sudo rm -f $BASE_IMG
fi
