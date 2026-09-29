#!/bin/bash
# Uso: ./create_vm.sh <VM_NAME> <OVS_NAME> <VLAN_ID> <VNC_PORT>
VM_NAME=$1
OVS_NAME=$2
VLAN_ID=$3
VNC_PORT=$4

BASE_IMG="/var/lib/libvirt/images/ubuntu_base.qcow2"
VM_DISK="/var/lib/libvirt/images/${VM_NAME}.qcow2"
TAP_DEV="tap_${VM_NAME}"

# Descargar o verificar imagen base
if [ ! -f "$BASE_IMG" ]; then
    sudo wget -O $BASE_IMG http://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img
fi

# Crear disco backing file (delta)
sudo qemu-img create -f qcow2 -b $BASE_IMG -F qcow2 $VM_DISK

# Crear interfaz TAP en OVS
sudo ip tuntap add dev $TAP_DEV mode tap
sudo ip link set $TAP_DEV up
sudo ovs-vsctl add-port $OVS_NAME $TAP_DEV tag=$VLAN_ID

# Arrancar VM con QEMU/KVM
sudo qemu-system-x86_64 -enable-kvm -m 1024 -smp 1 \
  -drive file=$VM_DISK,format=qcow2 \
  -netdev tap,id=net0,ifname=$TAP_DEV,script=no,downscript=no \
  -device e1000,netdev=net0 \
  -vnc :${VNC_PORT} -daemonize
