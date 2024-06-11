#!/bin/bash
#pedimos que se ejecute en sudo para que pueda eliminar los paquetes huerfanos
#revisamos si se ejecuto con sudo y si no se ejecuto con sudo entonces se cierra el script
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script con privilegios de superusuario"
    exit
fi

#Creamos una variable para guardar los huerfanos de paquetes 
huerfanos=$(pacman -Qdtq)

#Si la variable huerfanos esta vacia entonces no hay paquetes huerfanos 
if([ -z "$huerfanos" ]); then
    echo "No hay paquetes huerfanos"
else
    #Si la variable huerfanos no esta vacia entonces hay paquetes huerfanos
    echo "Paquetes huerfanos: $huerfanos"
    #Preguntamos si desea eliminar los paquetes huerfanos
    read -p "Desea eliminar los paquetes huerfanos? (s/n): " respuesta
    if [ $respuesta = "s" ]; then
        #Si la respuesta es si entonces eliminamos los paquetes huerfanos
        sudo pacman -Rs $huerfanos
        echo "Paquetes huerfanos eliminados"
    else
        #Si la respuesta es no entonces no eliminamos los paquetes huerfanos
        echo "No se eliminaron los paquetes huerfanos"
    fi
fi