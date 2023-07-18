[![PyTest](https://github.com/KubaTaba1uga/python_script_executor/actions/workflows/pytest.yml/badge.svg?branch=master)](https://github.com/KubaTaba1uga/python_script_executor/actions/workflows/pytest.yml) 
[![codecov](https://codecov.io/gh/KubaTaba1uga/python_script_executor/branch/master/graph/badge.svg?token=BHLC73ZGK0)](https://codecov.io/gh/KubaTaba1uga/python_script_executor)

# Requirements

1. Python >=3.9
2. Poetry

Python 3.9.8 installation:

	cd .prep
	/bin/bash install_python3_9.sh

Poetry installation:

	python3 -m pip install poetry


# App description 

Python Script Executor organize scripts in order and executes them.

In case of output or error, output controller perform desired actions.

If script return non 0 exit code, app stop another scripts execution and
ask You about desired action.

Tested scripts interpreters:

	- bash
	- python

# App installation

Execute below command inside repository directory:

	python3 -m poetry install --no-dev


# App usage 
 
Copy scripts You would like to execute to <repository_location>/scripts directory.

To order scripts add numbers preceded by `_` to their names ends. If numbers are missing
scripts will be executed randomly.

Script Name Examples:

	script_0.sh
	update-apt-get_1.sh
	update-upgrade_2.sh

To start app with default settings use:

	python3 -m poetry run python start.py

To show help use:

	python3 -m poetry run start.py -h

# Custom nat network iptables example
```
# This format is understood by iptables-restore. See `man iptables-restore`.

*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
# DHCP packets sent to VMs have no checksum (due to a longstanding bug).
-A POSTROUTING -o virbr10 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
# Do not masquerade to these reserved address blocks.
-A POSTROUTING -s 10.0.0.0/24 -d 224.0.0.0/24 -j RETURN
-A POSTROUTING -s 10.0.0.0/24 -d 255.255.255.255/32 -j RETURN
# Masquerade all packets going from VMs to the LAN/Internet.
-A POSTROUTING -s 10.0.0.0/24 ! -d 10.0.0.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
-A POSTROUTING -s 10.0.0.0/24 ! -d 10.0.0.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
-A POSTROUTING -s 10.0.0.0/24 ! -d 10.0.0.0/24 -j MASQUERADE
COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
# Allow established traffic to the private subnet.
-A FORWARD -d 10.0.0/24 -o virbr10 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Allow outbound traffic from the private subnet.
-A FORWARD -s 10.0.0.0/24 -i virbr10 -j ACCEPT
# Allow traffic between virtual machines.
-A FORWARD -i virbr10 -o virbr10 -j ACCEPT
# allow dhcp and dns
-A INPUT -i virbr10 -p udp -m udp -m multiport --dports 53,67 -j ACCEPT
-A INPUT -i virbr10 -p tcp -m tcp -m multiport --dports 53,67 -j ACCEPT
# Allow packets that have been forwarded to particular ports on the VM.
# -A FORWARD -d 10.0.0.77/32 -o virbr10 -p tcp -m tcp --syn -m conntrack --ctstate NEW -m multiport --dports 22,80,443 -j ACCEPT
# Reject everything else.
-A FORWARD -i virbr10 -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -o virbr10 -j REJECT --reject-with icmp-port-unreachable
COMMIT
```
