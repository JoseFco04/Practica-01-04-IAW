# Practica-01-04-IAW

## En esta práctica vammos a usar la misma máquina ubuntu que usamos en la practica 03 pero vamos a conifgurarle un certificado SSL autofirmado en apache 
### El script de *install_lamp* se haría así pero no cambia nada con respecto a la práctica anterior
~~~
###!/bin/bash
~~~
#### Muestra todos los comandos que se van ejecutando
~~~
set -x
~~~
#### Actualizamos los repositorios
~~~
apt update
~~~
#### Actualizamos los paquetes
~~~
apt upgrade -y
~~~
#### instalamos el servidor web Apache
~~~
apt install apache2 -y
~~~
#### Instalamos e sistema gestor de base de datos de mysql
~~~
apt install mysql-server -y
~~~
~~~
mysql -u $DB_USER -p $DP_PASSWD < .../sql/database.sql
~~~
#### Instalamos  PHP
~~~
apt install php libapache2-mod-php php-mysql -y
~~~
#### Copiar el archivo de configuración de Apache 
~~~
cp ../conf/000-default.conf /etc/apache2/sites-available
~~~
#### Reiniciamos el servicio Apache
~~~
systemctl restart apache2
~~~
#### Copiamos el archivo de prueba de php
~~~
cp ../php/index.php /var/www/html
~~~
#### Modificamos el propietario y el grupo del directorio /var/www/html
~~~
chown -R www-data:www-data /var/www/html
~~~
### Ahora pasamos a ver la configuración del archivo *.env* que guarda las variables que necesitamos para el certificado:
### Configuramos las variables con los datos que necesita el certificado
~~~
OPENSSL_COUNTRY="ES"
OPENSSL_PROVINCE="Almeria"
OPENSSL_LOCALITY="Almeria"
OPENSSL_ORGANIZATION="IES Celia"
OPENSSL_ORGUNIT="IAW"
OPENSSL_COMMON_NAME="practica-https.local"
OPENSSL_EMAIL="joseflopez65@gmail.com"
~~~
### Después tenemos dos archivos de configuración el primero el 000-default que sigue igual que en la práctica anterior y sería tal que así:
~~~
<VirtualHost *:80>
    #ServerName practica-https.local
    DocumentRoot /var/www/html

    # Redirige al puerto 443 (HTTPS)
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>
~~~
### Y Ahora tendríamos el archivo de configuración que necesitamos para nuestro certificado SSL que se va a llamar default-ssl-conf y quedaría así:
~~~
ServerSignature Off
ServerTokens Prod

<VirtualHost *:443>
    ServerName PUT_YOUR_DOMAIN_HERE
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
~~~
### Y por último tenemos nuestro script que es lo que cambia con respecto a la práctica anterior, es el *setup_selfisigned_certificate* y paso por paso se ve tal que así:
~~~
#!/bin/bash
~~~
#### Muestra todos los comandos que se van ejecutando 
~~~
set -x
~~~
#### Actualizamos los repositorios 
~~~
apt update 
~~~
#### Actualizamos los paquetes 
~~~
apt upgrade -y
~~~
#### Importamos el archivo de variables .env
~~~
source .env
~~~
#### Creamos un certificado y una clave privada 
~~~
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"
~~~
#### Copiamos el archivo de configuración de apache para https 
~~~
cp ../conf/default-ssl.conf /etc/apache2/sites-available/
~~~
#### Habilitamos el VirtualHost para HTTPS 
~~~
a2ensite default-ssl.conf
~~~
#### Habilitamos el modulo SSL
~~~
a2enmod ssl
~~~
#### Configuramos que las peticiones a HTTP se redirijan a HTTPS para ello copiamos el archivo *000-default.conf* en /etc/sites-available.
~~~
cp ../conf/000-default.conf /etc/apache2/sites-available
~~~
#### Sustituimos el nombre del dominio, lo hacemos buscando con el comando sed -i EL PUT_YOUR_DOMAIN_HERE que tenemos escrito en el archivo de configuración ssl.
~~~
sed -i "s/PUT_YOUR_DOMAIN_HERE/$OPENSSL_COMMON_NAME/g" /etc/apache2/sites-available/default-ssl.conf
~~~
#### Y Habilitamos el módulo 
~~~
a2enmod rewrite
~~~
#### Para finalizar reiniciamos el servicio de Apache
~~~
systemctl restart apache2
~~~
### Ahora una vez que entremos a la ip de nuestra máquina antes de acceder a la página web nos va a salir una advertencia de que no es un sitio seguro que si queremos seguir igualmente, sería algo así:
![Cap 1 p4](https://github.com/JoseFco04/Practica-01-04-IAW/assets/145347148/a659aa58-8a02-4fba-b029-92c5787d5be3)
### Le pinchariamos en ir igualmente y nos dejaria entrar perfectamente en nuestra página web.
