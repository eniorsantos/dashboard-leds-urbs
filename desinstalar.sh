#!/bin/sh
# ======================================================================
#  DESINSTALADOR - Dashboard Leds Urbs (Linux / macOS)
#  Remove os atalhos do Desktop e apaga a pasta instalada.
#
#  ATENCAO: apaga permanentemente o conteudo desta pasta!
# ======================================================================
PASTA="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"
DESK="$HOME/Desktop"

echo "======================================================================"
echo "  Desinstalar - Dashboard Leds Urbs"
echo "======================================================================"
echo
echo "  Pasta a remover: $PASTA"
echo
printf "Tem certeza? Digite SIM para confirmar: "
read OK || true
if [ "$OK" != "SIM" ]; then
  echo "  Cancelado."
  exit 0
fi

echo "[!] Removendo atalhos..."
if [ "$OS" = "Darwin" ]; then
  rm -f "$DESK/Dashboard Leds Urbs.command" "$DESK/Atualizar dados (Leds Urbs).command"
else
  if [ ! -d "$DESK" ]; then
    DESK="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
  fi
  rm -f "$DESK/Dashboard Leds Urbs.desktop" "$DESK/Atualizar dados (Leds Urbs).desktop"
fi
echo "[+] Atalhos removidos."

echo "[+] Removendo a pasta \"$PASTA\"..."
cd / || exit 1
(sleep 2; rm -rf "$PASTA") &
echo
echo "Desinstalacao concluida. Esta janela vai fechar."
sleep 3
exit 0