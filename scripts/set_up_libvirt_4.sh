#!/bin/bash

BRIDGE_NAME=virt-nat-bridge 
BRIDGE_IP=10.0.0.1

sudo systemctl enable --now libvirtd 

sudo usermod -a -G libvirt $USER 

# Custom Nat network
sudo virsh net-destroy default
sudo virsh net-autostart --disable default

RANDOM_MAC=$(hexdump -vn3 -e '/3 "52:54:00"' -e '/1 ":%02x"' -e '"\n"' /dev/urandom)
sudo ip link add $BRIDGE_NAME-dummy address $RANDOM_MAC type dummy

echo "auto $BRIDGE_NAME
iface $BRIDGE_NAME inet static
    # Make sure bridge-utils is installed!
    bridge_ports $BRIDGE_NAME-dummy
    bridge_stp on
    bridge_fd 2
    address $BRIDGE_IP
    netmask 255.255.255.0
    up /bin/systemctl start dnsmasq@$BRIDGE_NAME.service || :
    down /bin/systemctl stop dnsmasq@$BRIDGE_NAME.service || :
    " | sudo tee -a /etc/network/interfaces

sudo apt-get install -y net-tools

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo iptables-restore scripts/.nat-iptables

# dnsmasq
mkdir -p /var/lib/dnsmasq/$BRIDGE_NAME
touch /var/lib/dnsmasq/$BRIDGE_NAME/hostsfile
touch /var/lib/dnsmasq/$BRIDGE_NAME/leases

sudo cp scripts.dnmasq.conf /var/lib/dnsmasq/$BRIDGE_NAME/dnsmasq.conf
sudo touch /etc/dnsmasq.d/$BRIDGE_NAME.conf
echo "except-interface=$BRIDGE_NAME" | sudo tee -a /etc/dnsmasq.d/$BRIDGE_NAME.conf
echo "bind-interfaces" | sudo tee -a /etc/dnsmasq.d/$BRIDGE_NAME.conf
sudo service dnsmasq restart

sudo cp scripts/.dnmasq.service /etc/systemd/system/dnmasq@.service

sudo ifup $BRIDGE_NAME-dummy
sudo ifup $BRIDGE_NAME

