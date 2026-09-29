#!/bin/bash
# Uso: ./delete_vm.sh <VM_NAME> <OVS_NAME> <VLAN_ID> <VNC_PORT>
VM_NAME=$1
OVS_NAME=$2
TAP_DEV="tap_${VM_NAME}"
VM_DISK="/var/lib/libvirt/images/${VM_NAME}.qcow2"
BASE_IMG="/var/lib/libvirt/images/ubuntu_base.qcow2"

# Destruir proceso QEMU
sudo pkill -f "$VM_NAME" || true

# Eliminar puerto de OVS y TAP
sudo ovs-vsctl del-port $OVS_NAME $TAP_DEV 2>/dev/null || true
sudo ip link delete $TAP_DEV 2>/dev/null || true

# Eliminar disco delta
sudo rm -f $VM_DISK

# Si no hay más discos delta usando la imagen base, eliminar base
if ! ls /var/lib/libvirt/images/*.qcow2 2>/dev/null | grep -v "ubuntu_base.qcow2" > /dev/null; then
    sudo rm -f $BASE_IMG
fi
