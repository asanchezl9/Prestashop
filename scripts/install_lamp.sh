#!/bin/bash
set -ex

# Limpiar posibles saltos de linea de Windows (CRLF) en .env y conf
sed -i 's/\r$//' /vagrant/scripts/.env
sed -i 's/\r$//' /vagrant/conf/000-default.conf

# 1. Cargar las variables de entorno
source /vagrant/scripts/.env

# 2. Actualizar repositorios e instalar Apache y MariaDB
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y apache2 mariadb-server

# 3. Instalar PHP y las extensiones requeridas por PrestaShop
apt-get install -y php libapache2-mod-php php-mysql php-xml php-gd php-intl php-mbstring php-curl php-zip php-bcmath

# 4. Configurar las directivas de php.ini exigidas por PrestaShop (Apache y CLI)
for INI_FILE in /etc/php/8.1/apache2/php.ini /etc/php/8.1/cli/php.ini; do
    sed -i "s/;*memory_limit = .*/memory_limit = 256M/" "$INI_FILE"
    sed -i "s/;*max_input_vars = .*/max_input_vars = 5000/" "$INI_FILE"
    sed -i "s/;*post_max_size = .*/post_max_size = 128M/" "$INI_FILE"
    sed -i "s/;*upload_max_filesize = .*/upload_max_filesize = 128M/" "$INI_FILE"
done

# 5. Crear la base de datos y el usuario para PrestaShop
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -u root -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# 6. Copiar la configuracion del VirtualHost y habilitar mod_rewrite y headers
cp /vagrant/conf/000-default.conf /etc/apache2/sites-available/000-default.conf
sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
a2enmod rewrite
a2enmod headers
systemctl restart apache2