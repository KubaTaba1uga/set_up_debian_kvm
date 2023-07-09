#!/bin/bash

sudo systemctl enable --now libvirtd 

sudo usermod -a -G libvirt $USER 
sudo usermod -a -G libvirt-qemu $USER 
