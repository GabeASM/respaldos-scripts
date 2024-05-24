#!/bin/bash

# Dirección de la máquina remota y usuario
USUARIO_REMOTO="nodo2"
MAQUINA_REMOTA="192.168.1.197"

# Define el directorio de origen en la máquina local
DIRECTORIO_ORIGEN="/home/nodo1/respaldos/dir1"

# Define el directorio de destino en la máquina remota
DIRECTORIO_DESTINO="/home/${USUARIO_REMOTO}/respaldos/respaldos_rsync"

# Función para realizar un respaldo completo
respaldo_completo() {
    echo "Realizando un respaldo completo..."
    rsync -av --delete $DIRECTORIO_ORIGEN ${USUARIO_REMOTO}@${MAQUINA_REMOTA}:${DIRECTORIO_DESTINO}/backup_completo/
    echo "Respaldo completo realizado con éxito."
}

# Función para realizar un respaldo diferencial
respaldo_diferencial() {
    echo "Realizando un respaldo diferencial..."
    # Asegurarse de que existe un respaldo completo para comparar
    if ! ssh ${USUARIO_REMOTO}@${MAQUINA_REMOTA} test -d "${DIRECTORIO_DESTINO}/backup_completo"; then
        echo "Error: No existe un respaldo completo previo. Realice primero un respaldo completo."
        exit 1
    fi
    # Crea un directorio con la fecha actual para el respaldo diferencial
    FECHA=$(date +%Y%m%d)
    ssh ${USUARIO_REMOTO}@${MAQUINA_REMOTA} mkdir -p ${DIRECTORIO_DESTINO}/backup_diferencial/${FECHA}
    rsync -av --compare-dest=${DIRECTORIO_DESTINO}/backup_completo/ $DIRECTORIO_ORIGEN ${USUARIO_REMOTO}@${MAQUINA_REMOTA}:${DIRECTORIO_DESTINO}/backup_diferencial/${FECHA}/
    echo "Respaldo diferencial realizado con éxito."
}

# Menú para que el usuario elija el tipo de respaldo
echo "Seleccione el tipo de respaldo que desea realizar:"
echo "1) Respaldo completo"
echo "2) Respaldo diferencial"
read -p "Ingrese opción (1 o 2): " opcion

case $opcion in
    1)
        respaldo_completo
        ;;
    2)
        respaldo_diferencial
        ;;
    *)
        echo "Opción no válida."
        exit 1
        ;;
esac
