#!/bin/bash

#pedimos que se ejecute en sudo para que pueda instalar los paquetes necesarios para LAMP 
#revisamos si se ejecuto con sudo y si no se ejecuto con sudo entonces se cierra el script 
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script con privilegios de superusuario"
    exit
fi

#Instalamos los paquetes necesarios para LAMP
sudo pacman -S apache php php-apache mariadb phpmyadmin php-gd  --noconfirm

#Iniciamos el servicio de Apache 
sudo systemctl start httpd
sudo systemctl enable httpd

#Instalamos la base de datos MariaDB 
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

#Iniciamos el servicio de MariaDB
sudo systemctl start mysqld
sudo systemctl enable mysqld

#Le preguntamos al usario si desea escribir la configuracion de phpmyadmin en el archivo de configuracion de apache 
read -p "Desea escribir la configuracion de phpmyadmin en el archivo de configuracion de apache? (s/n): " respuesta

if [ $respuesta = "s" ]; then
    #creamos una copia de seguridad del archivo de configuracion de apache 
    sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
    #Habilitamos el modulo de php en apache 
    #buscamos la siguiente linea LoadModule mpm_event_module modules/mod_mpm_event.so en el archivo de configuracion de apache y la comentamos
    sudo sed -i 's/LoadModule mpm_event_module modules/mod_mpm_event.so/#LoadModule mpm_event_module modules/mod_mpm_event.so/g' /etc/httpd/conf/httpd.conf
    #buscamos la siguiente linea LoadModule mpm_prefork_module modules/mod_mpm_prefork.so en el archivo de configuracion de apache y la descomentamos
    sudo sed -i 's/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/g' /etc/httpd/conf/httpd.conf
    #Añadimos las siguientes lineas LoadModule php_module modules/libphp.so AddHandler php-script .php
    sudo echo "LoadModule php_module modules/libphp.so" >> /etc/httpd/conf/httpd.conf 
    sudo echo "AddHandler php-script .php" >> /etc/httpd/conf/httpd.conf
    sudo echo "Include conf/extra/php_module.conf" >> /etc/httpd/conf/httpd.conf
    #creamos el archivo phpmyadmin.conf en la siguiente ruta /etc/httpd/conf/extra/phpmyadmin.conf
    sudo touch /etc/httpd/conf/extra/phpmyadmin.conf 
    #escribimos la configuracion de phpmyadmin en el archivo phpmyadmin.conf
    sudo echo "Alias /phpmyadmin /usr/share/webapps/phpMyAdmin" >> /etc/httpd/conf/extra/phpmyadmin.conf
    sudo echo "<Directory /usr/share/webapps/phpMyAdmin>" >> /etc/httpd/conf/extra/phpmyadmin.conf
    sudo echo "    DirectoryIndex index.php" >> /etc/httpd/conf/extra/phpmyadmin.conf
    sudo echo "    AllowOverride All" >> /etc/httpd/conf/extra/phpmyadmin.conf
    sudo echo "    Options FollowSymlinks" >> /etc/httpd/conf/extra/phpmyadmin.conf
    sudo echo "    Require all granted" >> /etc/httpd/conf/extra/phpmyadmin.conf
    sudo echo "</Directory>" >> /etc/httpd/conf/extra/phpmyadmin.conf

    #Escribimos la configuracion de phpmyadmin en el archivo de configuracion de apache
    sudo echo "Include conf/extra/phpmyadmin.conf" >> /etc/httpd/conf/httpd.conf

    #creamos una copia de seguridad del archivo de configuracion de php.ini 
    sudo cp /etc/php/php.ini /etc/php/php.ini.bak
    #buscamos la siguiente linea ;extension=mysqli en el archivo de configuracion de php.ini y la descomentamos
    sudo sed -i 's/;extension=mysqli/extension=mysqli/g' /etc/php/php.ini
    #buscamos la siguiente linea ;extension=gd en el archivo de configuracion de php.ini y la descomentamos
    sudo sed -i 's/;extension=gd/extension=gd/g' /etc/php/php.ini
    #buscamos la siguiente linea ;extension=openssl en el archivo de configuracion de php.ini y la descomentamos
    sudo sed -i 's/;extension=openssl/extension=openssl/g' /etc/php/php.ini
    #buscamos la siguiente linea ;extension=pdo_mysql en el archivo de configuracion de php.ini y la descomentamos
    sudo sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/g' /etc/php/php.ini
    #buscamos la siguiente linea ;extension=zip en el archivo de configuracion de php.ini y la descomentamos
    sudo sed -i 's/;extension=zip/extension=zip/g' /etc/php/php.ini

    #Creamos una pagina html para probar que apache funciona correctamente 
    sudo touch /srv/http/index.html 
    sudo echo "<html>" >> /srv/http/index.html
    sudo echo "<head>" >> /srv/http/index.html
    sudo echo "<title>Prueba de Apache</title>" >> /srv/http/index.html
    sudo echo "</head>" >> /srv/http/index.html
    sudo echo "<body>" >> /srv/http/index.html
    sudo echo "<h1>¡Bienvenido a tu servidor!</h1>" >> /srv/http/index.html
    sudo echo "<a href='phpmyadmin'>phpMyAdmin</a>" >> /srv/http/index.html 
    sudo echo "</body>" >> /srv/http/index.html
    sudo echo "</html>" >> /srv/http/index.html

    echo "Se escribio la configuracion de phpmyadmin en el archivo de configuracion de apache desea reiniciar el servicio de apache? (s/n): "

    read respuesta

    if [ $respuesta = "s" ]; then
        #Si la respuesta es si entonces reiniciamos el servicio de apache
        sudo systemctl restart httpd
        echo "Se reinicio el servicio de apache"
    else
        #Si la respuesta es no entonces no reiniciamos el servicio de apache
        echo "No se reinicio el servicio de apache"
    fi

else
    #Si la respuesta es no entonces no escribimos la configuracion de phpmyadmin en el archivo de configuracion de apache
    echo "No se escribio la configuracion de phpmyadmin en el archivo de configuracion de apache"
fi

#Le preguntamos al usuario si desea configurar la base de datos MariaDB 
read -p "Desea configurar la base de datos MariaDB? (s/n): " respuesta

if [ $respuesta = "s" ]; then
    #Si la respuesta es si entonces configuramos la base de datos MariaDB
    sudo mysql_secure_installation
else
    #Si la respuesta es no entonces no configuramos la base de datos MariaDB
    echo "No se configuro la base de datos MariaDB"
fi
