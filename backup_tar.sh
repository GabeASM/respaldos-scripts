#!/bin/bash

# Define los directorios de origen y destino para los respaldos
DIRECTORIO_ORIGEN="/home/nodo1/respaldos/dir2"
DIRECTORIO_DESTINO_LOCAL="/home/nodo1/respaldos/respaldos_tar"
DIRECTORIO_DESTINO_REMOTO="nodo2@192.168.1.197:/home/nodo2/respaldos/respaldos_tar"

# Define el archivo donde se guardará la información para los respaldos incrementales
SNAPSHOT_FILE="${DIRECTORIO_DESTINO_LOCAL}/snapshot.file"

# Función para realizar un respaldo completo
respaldo_completo() {
    echo "Realizando un respaldo completo..."
    ARCHIVO="backup_completo_$(date +%Y%m%d_%H%M).tar.gz"
    tar -cvpzf ${DIRECTORIO_DESTINO_LOCAL}/${ARCHIVO} --exclude="${DIRECTORIO_DESTINO_LOCAL}" $DIRECTORIO_ORIGEN
    echo "Respaldo completo realizado con éxito."
    echo "Transfiriendo archivo a destino remoto..."
    scp ${DIRECTORIO_DESTINO_LOCAL}/${ARCHIVO} ${DIRECTORIO_DESTINO_REMOTO}
    echo "Transferencia completada."
}

# Función para realizar un respaldo incremental
respaldo_incremental() {
    echo "Realizando un respaldo incremental..."
    ARCHIVO="backup_incremental_$(date +%Y%m%d_%H%M).tar.gz"
    if [ ! -f $SNAPSHOT_FILE ]; then
        echo "No se encontró un archivo de snapshot, se creará uno nuevo."
    fi
    tar -cvpzf ${DIRECTORIO_DESTINO_LOCAL}/${ARCHIVO} -g $SNAPSHOT_FILE --exclude="${DIRECTORIO_DESTINO_LOCAL}" $DIRECTORIO_ORIGEN
    echo "Respaldo incremental realizado con éxito."
    echo "Transfiriendo archivo a destino remoto..."
    scp ${DIRECTORIO_DESTINO_LOCAL}/${ARCHIVO} ${DIRECTORIO_DESTINO_REMOTO}
    echo "Transferencia completada."
}

# Menú para que el usuario elija el tipo de respaldo
echo "Seleccione el tipo de respaldo que desea realizar:"
echo "1) Respaldo completo"
echo "2) Respaldo incremental"
read -p "Ingrese opción (1 o 2): " opcion

case $opcion in
    1)
        respaldo_completo
        ;;
    2)
        respaldo_incremental
        ;;
    *)
        echo "Opción no válida."
        exit 1
        ;;
esac