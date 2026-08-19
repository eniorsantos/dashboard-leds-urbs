#!/bin/sh
# Atualiza os dados do dashboard a partir da planilha "Leds Urbs" (Downloads ou Documents).
# Funciona em Linux e macOS.
cd "$(dirname "$0")" || exit 1

PY=$(command -v python3 || command -v python || true)
if [ -z "$PY" ]; then
  echo
  echo "Python nao encontrado - verifique se esta instalado."
  exit 1
fi

"$PY" atualizar_dados.py
ret=$?
if [ "$ret" -eq 0 ]; then
  echo
  echo "Pronto! Abra o arquivo dashboard/index.html no navegador."
else
  echo
  echo "Falhou - verifique se o Python esta instalado e com openpyxl:  pip install openpyxl"
fi
echo
cd / || true
read -r _ 2>/dev/null || true