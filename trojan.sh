#!/bin/bash

# Update & install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget unzip

# Hentikan proses Nginx lama dan bebaskan port 80
echo "Stopping any existing Nginx process..."
sudo systemctl stop nginx
sudo systemctl disable nginx
sudo rm /etc/systemd/system/nginx.service

# Unmask port 80 jika ada
echo "Unmasking port 80..."
sudo fuser -k 80/tcp

# Install Go
wget https://golang.org/dl/go1.19.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xvzf go1.19.4.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile

# Install Trojan-Go
cd /usr/local/bin
wget https://github.com/p4gefau1t/trojan-go/releases/download/v0.11.0/trojan-go-linux-amd64-v0.11.0.tar.gz
tar -xzvf trojan-go-linux-amd64-v0.11.0.tar.gz
rm trojan-go-linux-amd64-v0.11.0.tar.gz

# Setup configuration file
mkdir -p /etc/trojan-go
cat > /etc/trojan-go/config.json <<EOL
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 80,
  "remote_addr": "127.0.0.1",
  "remote_port": 443,
  "password": ["freenetaxis2025"],
  "ssl": {
    "enabled": false
  },
  "websocket": {
    "enabled": true,
    "path": "/axisws",
    "host": "api.ovo.id"
  }
}
EOL

# Setup systemd service for Trojan-Go
cat > /etc/systemd/system/trojan-go.service <<EOL
[Unit]
Description=Trojan-Go Service
After=network.target

[Service]
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure
User=root
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start Trojan-Go
sudo systemctl daemon-reload
sudo systemctl start trojan-go
sudo systemctl enable trojan-go

echo "Trojan-Go has been installed and started successfully on IP 8.215.192.205!"
