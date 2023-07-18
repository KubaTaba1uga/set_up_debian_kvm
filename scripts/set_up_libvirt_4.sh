#!/bin/bash

BRIDGE_NAME=virt-nat-bridge 
BRIDGE_IP=10.0.0.1

sudo systemctl enable --now libvirtd 

sudo usermod -a -G libvirt $USER 

# Custom Nat network
sudo virsh net-destroy default
sudo virsh net-autostart --disable default

RANDOM_MAC=$(hexdump -vn3 -e '/3 "52:54:00"' -e '/1 ":%02x"' -e '"\n"' /dev/urandom)
ip link add $BRIDGE_NAME-dummy address $RANDOM_MAC type dummy

auto $BRIDGE_NAME
iface $BRIDGE_NAME inet static
    # Make sure bridge-utils is installed!
    bridge_ports $BRIDGE_NAME-dummy
    bridge_stp on
    bridge_fd 2
    address $BRIDGE_IP
    netmask 255.255.255.0
