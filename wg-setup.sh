#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== 1. Updating package lists ==="
sudo apt update

echo "=== 2. Installing WireGuard and Net-Tools ==="
sudo apt install -y wireguard net-tools

echo "=== 3. Checking network interfaces ==="
ip route show default

echo "=== 4. Configuring sysctl for IP forwarding ==="
if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
fi
sudo sysctl -p

echo "=== 5. Writing WireGuard configuration ==="
sudo mkdir -p /etc/wireguard

# Write wg0.conf automatically
sudo tee /etc/wireguard/wg0.conf > /dev/null << 'EOF'
[Interface]
Address = 203.0.130.5/24
SaveConfig = false

# Ensure enp0s3 matches your actual internet-facing interface name
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s3 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o enp0s3 -j MASQUERADE

ListenPort = 51820
PrivateKey = 4NlPzkaVjy8Gex+9tpwIzNnCqFz6A1kO/D8jDL4ewnA=

[Peer]
# Add the peer's public IP and port here if this node initiates the connection:
# Endpoint = remote_peer_public_ip:51820
PublicKey = C+GBEabyq8/8tRFeR24IqX0oCKPaVkzw27PvidwxHB8=
AllowedIPs = 203.0.130.45/32
EOF

# Secure the configuration file permissions (contains private key)
sudo chmod 600 /etc/wireguard/wg0.conf

echo "=== 6. Bringing up the WireGuard interface ==="
cd /etc/wireguard
sudo wg-quick down wg0 2>/dev/null || true
sudo wg-quick up wg0

echo "=== 7. Verifying WireGuard status ==="
sudo wg

echo "=== 8. Applying iptables NAT rule ==="
# Replace 'enp0s3' with your actual public network interface if different
sudo iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 62643 -j DNAT --to 203.0.130.45:62643

echo "=== Setup Complete! ==="
