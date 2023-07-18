#!/bin/bash

BRIDGE_NAME=virtbr0nat
BRIDGE_IP=10.0.0.1

sudo modepbrobe dummy

sudo systemctl enable --now libvirtd 

sudo usermod -a -G libvirt $USER 

# Custom Nat network
sudo virsh net-destroy default
sudo virsh net-autostart --disable default

RANDOM_MAC=$(hexdump -vn3 -e '/3 "52:54:00"' -e '/1 ":%02x"' -e '"\n"' /dev/urandom)

echo "# dummy interface
auto dummy0
iface dummy0 inet manual
    pre-up /sbin/ip link add dummy0 type dummy
    up /sbin/ip link set dummy0 address $RANDOM_MAC

" | sudo tee -a /etc/network/interfaces

sudo systemctl restart networking

echo "# bridge interface
auto $BRIDGE_NAME
iface $BRIDGE_NAME inet static
    # Make sure bridge-utils is installed!
    bridge_ports dummy0
    bridge_stp on
    bridge_fd 2
    address $BRIDGE_IP
    netmask 255.255.255.0
    up /bin/systemctl start dnsmasq@$BRIDGE_NAME.service || :
    down /bin/systemctl stop dnsmasq@$BRIDGE_NAME.service || :
    " | sudo tee -a /etc/network/interfaces

sudo systemctl restart networking

sudo apt-get install -y net-tools

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo iptables-restore scripts/.nat-iptables

# dnsmasq
sudo mkdir -p /var/lib/dnsmasq/$BRIDGE_NAME
sudo touch /var/lib/dnsmasq/$BRIDGE_NAME/hostsfile
sudo touch /var/lib/dnsmasq/$BRIDGE_NAME/leases

sudo mkdir /var/lib/dnsmasq/$BRIDGE_NAME
sudo cp scripts/.dnsmasq.conf /var/lib/dnsmasq/$BRIDGE_NAME/dnsmasq.conf

sudo mkdir -p /etc/dnsmasq.d
sudo touch /etc/dnsmasq.d/$BRIDGE_NAME.conf
echo "except-interface=$BRIDGE_NAME" | sudo tee -a /etc/dnsmasq.d/$BRIDGE_NAME.conf
echo "bind-interfaces" | sudo tee -a /etc/dnsmasq.d/$BRIDGE_NAME.conf

sudo cp scripts/.dnsmasq.service /etc/systemd/system/dnsmasq@.service

sudo ifup dummy0
sudo ifup $BRIDGE_NAME

