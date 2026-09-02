#!/usr/bin/env bash
# Script para configurar el enrutamiento del módem USB 4G de Orange en Raspberry Pi (smith)
# Interfaz Ethernet oficina: eth0 (192.168.40.31)
# Interfaz Módem USB 4G: wwan0 / ppp0

set -euo pipefail

MODEM_IF="${1:-wwan0}"
ROUTING_TABLE="4g_orange"
MARK_ID="4"

echo "[*] Configurando enrutamiento para interfaz $MODEM_IF..."

# 1. Asegurar tabla en /etc/iproute2/rt_tables
if ! grep -q "$ROUTING_TABLE" /etc/iproute2/rt_tables; then
    echo "200 $ROUTING_TABLE" >> /etc/iproute2/rt_tables
fi

# 2. Obtener gateway del módem
GATEWAY_IP=$(ip route show dev "$MODEM_IF" | grep default | awk '{print $3}' || true)

if [ -n "$GATEWAY_IP" ]; then
    ip route replace default via "$GATEWAY_IP" dev "$MODEM_IF" table "$ROUTING_TABLE"
    echo "[+] Default route para $ROUTING_TABLE establecida via $GATEWAY_IP dev $MODEM_IF"
fi

# 3. Reglas de IP para paquetes marcados
ip rule del fwmark "$MARK_ID" table "$ROUTING_TABLE" 2>/dev/null || true
ip rule add fwmark "$MARK_ID" table "$ROUTING_TABLE"

echo "[✓] Configuración de enrutamiento 4G completada."
