#!/bin/sh
apt autoremove iptables -y
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
certbot certonly --apache -d www.donpau.com --non-interactive --register-unsafely-without-email --agree-tos
certbot renew --dry-run
mkdir -p /var/www/www.donpau.com
chmod -R 755 /var/www/www.donpau.com