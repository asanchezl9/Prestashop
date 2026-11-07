#!/bin/bash
set -ex

source /vagrant/scripts/.env

# 1. Instalar Certbot y OpenSSL
export DEBIAN_FRONTEND=noninteractive
apt-get install -y certbot python3-certbot-apache openssl
a2enmod ssl

# 2. Generar certificado SSL autofirmado para el entorno local
mkdir -p /etc/apache2/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/apache2/ssl/prestashop.key \
  -out /etc/apache2/ssl/prestashop.crt \
  -subj "/C=ES/ST=Badajoz/L=Merida/O=IES/OU=ASIR/CN=$CERTIFICATE_DOMAIN"

# 3. Configurar Apache para usar el certificado autofirmado
sed -i 's|/etc/ssl/certs/ssl-cert-snakeoil.pem|/etc/apache2/ssl/prestashop.crt|g' /etc/apache2/sites-available/default-ssl.conf
sed -i 's|/etc/ssl/private/ssl-cert-snakeoil.key|/etc/apache2/ssl/prestashop.key|g' /etc/apache2/sites-available/default-ssl.conf

# 4. Habilitar el sitio HTTPS y reiniciar
a2ensite default-ssl.conf
systemctl restart apache2

# (Opcional) Comando real para produccion con dominio publico:
# certbot --apache -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive