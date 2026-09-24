#!/bin/bash
# Uso: ./create_vm.sh <NOMBRE_VM> <NOMBRE_OVS> <VLAN_ID> <PUERTO_VNC>

VM_NAME=$1
OVS_BR=$2
VLAN_ID=$3
VNC_PORT=$4

BASE_DIR="/var/lib/libvirt/images"
BASE_IMG="${BASE_DIR}/ubuntu-base.qcow2"
VM_DISK="${BASE_DIR}/${VM_NAME}.qcow2"

if [ ! -f "$BASE_IMG" ]; then
    sudo wget -O $BASE_IMG https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img
fi

sudo qemu-img create -f qcow2 -b $BASE_IMG -F qcow2 $VM_DISK 10G

sudo virt-install \
  --name $VM_NAME \
  --ram 1024 \
  --vcpus 1 \
  --disk path=$VM_DISK,format=qcow2 \
  --network bridge=$OVS_BR,portgroup=vlan-$VLAN_ID,model=virtio \
  --graphics vnc,port=$VNC_PORT,listen=0.0.0.0 \
  --noautoconsole \
  --import
