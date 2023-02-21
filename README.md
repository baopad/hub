# 0
"A:  ray.paotung.org    	66.152.171.78    "<br>
"CNAME:  rcdn.paotung.org    	ray.paotung.org"<br>
"CNAME:  rays.paotung.org    	baopad.github.io"
# rays
apt install apache2<br>
echo "ServerName 127.0.0.1:80" >> /etc/apache2/apache2.conf<br>
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf<br>
echo "ServerSignature Off" >> /etc/apache2/apache2.conf<br>
a2enmod proxy proxy_wstunnel ssl rewrite headers proxy_http proxy_http2<br>
systemctl restart apache2
# rays
apt install snapd
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot certonly --apache -d ray.paotung.org -d rcdn.paotung.org
certbot renew --dry-run

# rays
Personal GoogleDrive/SVN directory.
