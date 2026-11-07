#!/bin/bash
set -ex

source /vagrant/scripts/.env

# 1. Limpiar /var/www/html y descargar script de comprobacion PhpPsInfo
rm -rf /var/www/html/* /var/www/html/.* 2>/dev/null || true
wget -q https://raw.githubusercontent.com/PrestaShop/php-ps-info/master/phppsinfo.php -O /var/www/html/phppsinfo.php

# 2. Descargar y descomprimir PrestaShop en modo silencioso (-oq)
export DEBIAN_FRONTEND=noninteractive
apt-get install -y unzip
wget -q https://github.com/PrestaShop/PrestaShop/releases/download/8.1.2/prestashop_8.1.2.zip -O /tmp/prestashop.zip
unzip -oq /tmp/prestashop.zip -d /var/www/html/
unzip -oq /var/www/html/prestashop.zip -d /var/www/html/
rm -f /var/www/html/prestashop.zip /tmp/prestashop.zip /var/www/html/index.html

# 3. Asignar permisos al usuario de Apache
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# 4. Instalacion automatizada por CLI (con SSL activado)
cd /var/www/html/install
sudo -u www-data php index_cli.php \
  --domain="$PS_DOMAIN" \
  --ssl=1 \
  --db_server="127.0.0.1" \
  --db_name="$DB_NAME" \
  --db_user="$DB_USER" \
  --db_password="$DB_PASSWORD" \
  --firstname="Amparo" \
  --lastname="Sanchez" \
  --password="$PS_PASS" \
  --email="$PS_EMAIL" \
  --language="$PS_LANGUAGE" \
  --country="$PS_COUNTRY"

# 5. Borrar carpeta install, renombrar admin y limpiar cache/permisos
rm -rf /var/www/html/install
mv /var/www/html/admin /var/www/html/admin_amparo
rm -rf /var/www/html/var/cache/*
chown -R www-data:www-data /var/www/html/
systemctl restart apache2