#!/bin/bash

sudo apt-get update

sudo apt-get install qemu-kvm -y




sudo systemctl enable --now libvirtd 

sudo usermod -a -G libvirt $USER 
sudo usermod -a -G libvirt-qemu $USER 
sudo usermod -a -G kvm $USER 
