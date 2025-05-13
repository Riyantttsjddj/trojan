#!/bin/bash

echo "=== TROJAN-GO AUTO INSTALLER ==="

# 1. Update dan pasang dependensi
apt update && apt upgrade -y
apt install -y curl unzip wget sudo

# 2. Stop dan matikan Nginx agar tidak bentrok dengan port 80/443
echo "[+] Mematikan Nginx jika ada..."
systemctl stop nginx >/dev/null 2>&1
systemctl disable nginx >/dev/null 2>&1
fuser -k 80/tcp || true
fuser -k 443/tcp || true

# 3. Buat folder instalasi
mkdir -p /usr/local/bin/trojan-go
cd /usr/local/bin/trojan-go

# 4. Download Trojan-Go versi terbaru
echo "[+] Mengunduh Trojan-Go versi terbaru..."
wget -O trojan-go.zip https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-linux-amd64.zip
unzip trojan-go.zip
chmod +x trojan-go
rm trojan-go.zip

# 5. Buat folder konfigurasi
mkdir -p /etc/trojan-go

# 6. Buat config.json dengan multi host
cat > /etc/trojan-go/config.json <<EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 443,
  "remote_addr": "127.0.0.1",
  "remote_port": 80,
  "password": ["freenetaxis2025"],
  "ssl": {
    "cert": "/etc/ssl/certs/ssl-cert-snakeoil.pem",
    "key": "/etc/ssl/private/ssl-cert-snakeoil.key"
  },
  "websocket": {
    "enabled": true,
    "path": "/axisws",
    "host": [
      "api.ovo.id",
      "my.udemy.com",
      "dev.appsflyer.com"
    ]
  }
}
EOF

# 7. Pastikan sertifikat snakeoil tersedia
apt install -y ssl-cert

# 8. Buat systemd service
cat > /etc/systemd/system/trojan-go.service <<EOF
[Unit]
Description=Trojan-Go Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/trojan-go/trojan-go -config /etc/trojan-go/config.json
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 9. Aktifkan service
echo "[+] Menjalankan Trojan-Go..."
systemctl daemon-reload
systemctl enable trojan-go
systemctl restart trojan-go

# 10. Cek status
sleep 2
systemctl status trojan-go --no-pager

echo ""
echo "=== INSTALASI SELESAI ==="
echo "IP VPS Anda: $(curl -s ifconfig.me)"
echo "Port       : 443 (SSL + WS)"
echo "Path WS    : /axisws"
echo "Password   : freenetaxis2025"
echo "Multi Host : api.ovo.id, my.udemy.com, dev.appsflyer.com"
echo ""
