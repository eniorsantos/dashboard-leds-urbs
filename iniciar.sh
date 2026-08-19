#!/bin/sh
# Inicia um servidor local e abre o dashboard no navegador.
# Necessario para o Google Sheets ser aceito (CORS): abrindo o
# index.html direto (file://) o Google bloqueia com "Failed to fetch".
# Funciona em Linux e macOS.
cd "$(dirname "$0")" || exit 1

PY=$(command -v python3 || command -v python || true)
if [ -z "$PY" ]; then
  echo "Python nao encontrado - verifique se esta instalado."
  exit 1
fi

echo "--------------------------------------------------------------------"
echo "  Servidor do dashboard:  http://localhost:8000/dashboard/"
echo "  Abrindo no navegador..."
echo "  Para parar: feche esta janela ou pressione Ctrl+C."
echo "--------------------------------------------------------------------"

case "$(uname -s)" in
  Darwin) open "http://localhost:8000/dashboard/" ;;
  *)      xdg-open "http://localhost:8000/dashboard/" >/dev/null 2>&1 || true ;;
esac

"$PY" servidor.py
ret=$?
if [ "$ret" -ne 0 ]; then
  echo
  echo "Falhou ao iniciar o servidor - verifique se o Python esta instalado."
  cd / || true
  read -r _ 2>/dev/null || true
fi