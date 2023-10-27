#!/bin/bash

# Muestra todos los comandos que se van ejecutando 
set -x

# Actualizamos los repositorios 
apt update 

# Actualizamos los paquetes 
# apt upgrade -y

# Importamos el archivo de variables .env
source .env

# Creamoos un certificado y una clave privada 
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"

  # Copiamos el archivo de configuración de apache para https
  cp ../conf/default-ssl.conf /etc/apache2/sites-available/

  # Habilitamos el VirtualHost para HTTPS 
  a2ensite default-ssl.conf

  # Habilitamos el modulo SSL
  a2enmod ssl

  #Configuramos que las peticiones a HTTP se redirijan a HTTPS
  # Copiamos el archivo de configuracion de VirtualHost para HTTP
  cp ../conf/000-default.conf /etc/apache2/sites-available

  # Sustituimos el nombre del dominio
  sed -i "s/PUT_YOUR_DOMAIN_HERE/$OPENSSL_COMMON_NAME/g" /etc/apache2/sites-available/default-ssl.conf
  # Habilitamos el módulo 
  a2enmod rewrite

  # Reiniciamos el servicio de Apache
  systemctl restart apache2