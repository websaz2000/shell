#!/bin/bash

#curl -sSL https://raw.githubusercontent.com/websaz2000/shell/main/atlas_wg.sh | sudo bash
# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run this script with sudo or as root."
  exit 1
fi

# Define directory and fixed file path
CONFIG_DIR="/var/bitso_repo/wireguard"
CONFIG_FILE="$CONFIG_DIR/aeza_ip45.conf"

# Verify directory exists; throw an error and exit if it doesn't
if [ ! -d "$CONFIG_DIR" ]; then
  echo "[-] Error: Directory $CONFIG_DIR does not exist."
  exit 1
fi

# Ask the user for the IP address
read -p "Enter the IP address: " ip_param

if [ -z "$ip_param" ]; then
  echo "[-] Error: IP input cannot be empty."
  exit 1
fi

# Generate or overwrite the WireGuard configuration file
cat << EOF > "$CONFIG_FILE"
[Interface]
PrivateKey = aJuFT/LmD7/nqMoufgpN97vJ7UOKU65wNJRaW+5f+nc=
Address = 203.0.130.45/32
DNS = 1.1.1.1
MTU = 1420

#Table = 8888
PreUp = ip route add 95.216.149.33/32 via 172.17.0.1 dev eth0
PostDown = ip route del 95.216.149.33/32 via 172.17.0.1 dev eth0
PreUp = ip route add 65.21.1.68/32 via 172.17.0.1 dev eth0
PostDown = ip route del 65.21.1.68/32 via 172.17.0.1 dev eth0

[Peer]
PublicKey = ZoLIz4RiWzWWy56Tjc2zSR3DTETkzzFVehFPbTOfwhk=
AllowedIPs = 0.0.0.0/0
Endpoint = ${ip_param}:51820
PersistentKeepalive = 25
EOF

echo "[+] WireGuard configuration successfully written to: $CONFIG_FILE"
echo "[+] WireGuard configuration successfully written to: $CONFIG_FILE"
