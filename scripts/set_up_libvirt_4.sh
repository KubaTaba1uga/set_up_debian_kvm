#!/bin/bash

sudo systemctl enable --now libvirtd 

sudo usermod -a -G libvirt $USER 

sudo virsh net-start default
sudo virsh net-autostart default
