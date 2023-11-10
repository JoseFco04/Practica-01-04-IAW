# Practica-01-04-IAW

### En esta práctica vammos a usar la misma máquina ubuntu que usamos en la practica 03 pero 
#!/bin/bash

## Muestra todos los comandos que se van ejecutando
set -x

# Actualizamos los repositorios
apt update

# Actualizamos los paquetes
apt upgrade -y

# instalamos el servidor web Apache
apt install apache2 -y

# Instalamos e sistema gestor de base de datos de mysql
apt install mysql-server -y

#mysql -u $DB_USER -p $DP_PASSWD < .../sql/database.sql

# Instalamos  PHP
apt install php libapache2-mod-php php-mysql -y

# Copiar el archivo de configuración de Apache 
cp ../conf/000-default.conf /etc/apache2/sites-available
# Reiniciamos el servicio Apache
systemctl restart apache2

# Copiamos el archivo de prueba de php
cp ../php/index.php /var/www/html

# Modificamos el propietario y el grupo del directorio /var/www/html

chown -R www-data:www-data /var/www/html
