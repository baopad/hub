# 0
"A:  ray.paotung.org    	66.152.171.78    "<br>
"CNAME:  rcdn.paotung.org    	ray.paotung.org"<br>
"CNAME:  rays.paotung.org    	baopad.github.io"
# Install Apache
apt install apache2<br>
echo "ServerName 127.0.0.1:80" >> /etc/apache2/apache2.conf<br>
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf<br>
echo "ServerSignature Off" >> /etc/apache2/apache2.conf<br>
a2enmod proxy proxy_wstunnel ssl rewrite headers proxy_http proxy_http2<br>
systemctl restart apache2
# Install Snapd
apt install snapd<br>
snap install core<br>
snap refresh core<br>
snap install --classic certbot<br>
ln -s /snap/bin/certbot /usr/bin/certbot<br>
certbot certonly --apache -d ray.paotung.org -d rcdn.paotung.org<br>
certbot renew --dry-run

# Apache&Snapd configuration
certbot certonly --apache -d ray.paotung.org -d rcdn.paotung.org<br>
certbot renew --dry-run<br>
mkdir -p /var/www/ray.paotung.org<br>
cat > /etc/apache2/sites-available/./ray.paotung.org.conf <<EOF<br>
<VirtualHost *:80><br>
    ServerAdmin info@paotung.org<br>
    ServerName ray.paotung.org<br>
    ServerAlias rcdn.paotung.org<br>
    DocumentRoot "/var/www/ray.paotung.org"<br>
    RewriteEngine On<br>
    RewriteCond %{HTTPS} off<br>
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]<br>
</VirtualHost><br>
<VirtualHost *:443><br>
    ServerAdmin info@paotung.org<br>
    ServerName ray.paotung.org<br>
    ServerAlias rcdn.paotung.org<br>
    DocumentRoot "/var/www/ray.paotung.org"<br>
    <Directory /var/www/><br>
        Options -Indexes +FollowSymLinks<br>
        AllowOverride None<br>
        Require all granted<br>
    </Directory><br>
    ErrorDocument 403 "/error/403.html"<br>
    ErrorDocument 404 "/error/404.html"<br>
    SSLProxyEngine On<br>
    ProxyPass "/" "https://rays.paotung.org/"<br>
    ProxyPassReverse "/" "https://rays.paotung.org/"<br>
    SSLEngine On<br>
    SSLCertificateFile "/etc/letsencrypt/live/ray.paotung.org/fullchain.pem"<br>
    SSLCertificateKeyFile "/etc/letsencrypt/live/ray.paotung.org/privkey.pem"<br>
    Include "/etc/letsencrypt/options-ssl-apache.conf"<br>
</VirtualHost><br>
EOF<br>
a2ensite ray.paotung.org.conf<br>
apache2ctl configtest<br>

