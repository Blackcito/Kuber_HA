#!/usr/bin/env bash
set -euo pipefail

# Usuario SSH que puede apagar las VMs
SSH_USER="amellado"

# VIP y desfase entre arranques
DELAY_START=30

# Definimos nombres e IPs al mismo índice
VM_NAMES=(onenodo1 onenodo2 onenodo3)
VM_IPS=(172.16.25.11 172.16.25.12 172.16.25.13)

echo "=== Paso 1: Apagar nodos vía SSH ==="
for i in "${!VM_IPS[@]}"; do
    ip=${VM_IPS[i]}
    name=${VM_NAMES[i]}
    echo -n " -> Apagando $name ($ip)… "
    ssh -o BatchMode=yes "${SSH_USER}@${ip}" sudo poweroff \
      && echo "sent" \
      || echo "falló (¿ya estaba apagado?)"
done

echo
echo "=== Paso 2: Esperar a que estén ‘shut off’ ==="
for name in "${VM_NAMES[@]}"; do
    echo -n " -> Esperando a $name… "
    # Loop hasta que virsh reporte “shut off”
    until virsh domstate "$name" 2>/dev/null | grep -q "shut off"; do
        printf "."
        sleep 2
    done
    echo " OK"
done

echo
echo "=== Paso 3: Arrancar en orden con ${DELAY_START}s de desfase ==="
for name in "${VM_NAMES[@]}"; do
    echo -n " -> Iniciando $name… "
    virsh start "$name"
    echo "OK, durmiendo $DELAY_START s"
    sleep $DELAY_START
done

echo
echo "=== ¡Hecho! Todas las VMs han sido reiniciadas. ==="

