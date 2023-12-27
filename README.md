# 0
https://ray.paotung.org<br>
https://rays.paotung.org<br>
https://rcdn.paotung.org<br>
# Install Apache
apt install apache2<br>
echo "ServerName 127.0.0.1:80" >> /etc/apache2/apache2.conf<br>
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf<br>
echo "ServerSignature Off" >> /etc/apache2/apache2.conf<br>
a2enmod proxy proxy_wstunnel ssl rewrite headers proxy_http proxy_http2<br>
systemctl restart apache2
# Install Snapd

