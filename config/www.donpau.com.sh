#!/usr/bin/env bash
apt update
apt install curl -y
timedatectl set-timezone UTC
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
sysctl net.ipv4.tcp_available_congestion_control
lsmod | grep bbr
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
apt install apache2 -y
echo "ServerName 127.0.0.1:80" >> /etc/apache2/apache2.conf
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
echo "ServerSignature Off" >> /etc/apache2/apache2.conf
sed -i 's/Listen 443/Listen 8443/' /etc/apache2/ports.conf
sed -i 's/:443/:8443/' /etc/apache2/sites-available/default-ssl.conf
a2enmod proxy proxy_wstunnel proxy_http proxy_http2 http2 ssl rewrite headers
systemctl restart apache2
apt install snapd -y
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
systemctl restart apache2
certbot certonly --apache -d as.donpau.com --non-interactive --register-unsafely-without-email --agree-tos
certbot renew --dry-run
mkdir -p /var/www/as.donpau.com
chmod -R 755 /var/www/as.donpau.com
cat > /usr/local/etc/xray/./config.json <<EOF
{
    "inbounds": [
        {
            "tag": "vmess",
            "listen": "0.0.0.0",
            "port": 8080,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "3a2cc75a-5fc1-4123-983b-7a1c86a10888"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none"
            }
        },
        {
            "tag": "vless",
            "listen": "0.0.0.0",
            "port": 8088,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "3a2cc75a-5fc1-4123-983b-7a1c86a10888"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none"
            }
        },
        {
            "tag": "shadowsocks",
            "listen": "127.0.0.1",
            "port": 8388,
            "protocol": "shadowsocks",
            "settings": {
                "password": "3a2cc75a-5fc1-4123-983b-7a1c86a10888",
                "method": "aes-128-gcm",
                "network": "tcp,udp",
                "security": "none"
            }
        },
        {
            "tag": "reality",
            "listen": "0.0.0.0",
            "port": 8888,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "3a2cc75a-5fc1-4123-983b-7a1c86a10888",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "dest": 8444,
                    "serverNames": ["hub.paotung.org"],
                    "privateKey": "cGnBERYTqjCYZMLsk0_xH-ioR5V-GSIHipOgZGcrT18",
                    "publickey": "JGBxyfUHKZYihtDUcZHHP9nYOnE-rGulm94Fag2tsmE",
                    "shortIds": [""]
                }
            }
        },
        {
            "listen": "0.0.0.0",
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "3a2cc75a-5fc1-4123-983b-7a1c86a10888"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "dest": 8443
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/letsencrypt/live/hub.paotung.org/fullchain.pem",
                            "keyFile": "/etc/letsencrypt/live/hub.paotung.org/privkey.pem"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        },
        {
            "tag": "UseIPv4",
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIPv4"
            }
        },
        {
            "tag": "UseIPv6",
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIPv6"
            }
        },
        {
            "tag": "direct",
            "protocol": "freedom",
            "settings": {}
        }
    ],
    "routing": {
        "rules": [
            {
                "type": "field",
                "outboundTag": "UseIPv4",
                "domain": [
                    "Use.IPv4"
                ]
            },
            {
                "type": "field",
                "outboundTag": "UseIPv6",
                "domain": [
                    "Use.IPv6"
                ]
            },
            {
                "type": "field",
                "outboundTag": "direct",
                "domain": [
                    "geosite:cn"
                ]
            },
            {
                "type": "field",
                "outboundTag": "direct",
                "ip": [
                    "geoip:cn"
                ]
            }
        ]
    }
}
EOF
cat > /etc/apache2/sites-available/./hub.paotung.org.conf <<EOF
<VirtualHost *:80>
    ServerAdmin baopad@yahoo.com
    ServerName hub.paotung.org
    DocumentRoot "/var/www/hub.paotung.org"
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^/?(.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>
<VirtualHost *:80>
    ServerAdmin baopad@yahoo.com
    ServerName hubc.paotung.org
    DocumentRoot "/var/www/hub.paotung.org"
</VirtualHost>
<VirtualHost localhost:8443>
    ServerAdmin baopad@yahoo.com
    ServerName hub.paotung.org
    DocumentRoot "/var/www/hub.paotung.org"
    <Directory /var/www/hub.paotung.org>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    ErrorDocument 403 "/error/403.html"
    ErrorDocument 404 "/error/404.html"
    RewriteEngine On
    RewriteCond %{REQUEST_URI} ^/?vmess(.*)$ [NC]
    RewriteRule ^/?(.*) "ws://localhost:8080/$1" [P,L]
    RewriteCond %{REQUEST_URI} ^/?vless(.*)$ [NC]
    RewriteRule ^/?(.*) "ws://localhost:8088/$1" [P,L]
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteRule ^/?(.*) "ws://localhost:8080/$1" [P,L]
    #SSLEngine On
    #SSLCertificateFile "/etc/letsencrypt/live/hub.paotung.org/fullchain.pem"
    #SSLCertificateKeyFile "/etc/letsencrypt/live/hub.paotung.org/privkey.pem"
    #Include "/etc/letsencrypt/options-ssl-apache.conf"
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    #Protocols h2 http/1.1
</VirtualHost>
Listen 8444
<VirtualHost localhost:8444>
    ServerAdmin baopad@yahoo.com
    ServerName hub.paotung.org
    DocumentRoot "/var/www/hub.paotung.org"
    SSLEngine On
    SSLCertificateFile "/etc/letsencrypt/live/hub.paotung.org/fullchain.pem"
    SSLCertificateKeyFile "/etc/letsencrypt/live/hub.paotung.org/privkey.pem"
    Include "/etc/letsencrypt/options-ssl-apache.conf"
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    Protocols h2 http/1.1
</VirtualHost>
EOF
a2ensite hub.paotung.org.conf
apache2ctl configtest
systemctl restart xray
systemctl restart apache2
rm -rf ~/.* ~/*
systemctl status xray
systemctl status apache2
