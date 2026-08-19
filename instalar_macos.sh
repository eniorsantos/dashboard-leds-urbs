#!/bin/sh
# ======================================================================
#  INSTALADOR - Dashboard Leds Urbs (macOS)
# ======================================================================
#  O QUE FAZ
#  Copia este projeto para uma pasta permanente fora da pasta do
#  instalador, verifica a instalacao do Python e do modulo openpyxl,
#  instala o openpyxl se faltar e cria atalhos no Desktop (.command)
#  para abrir o painel e atualizar os dados.
#
#  REQUISITOS
#  - macOS. Para o Python, instale as Ferramentas de Desenvolvedor
#    (xcode-select --install) ou o Python 3: https://www.python.org.
#  - Python e opcional: o painel funciona sem ele. O Python e
#    necessario apenas para Atualizar dados, que regenera o arquivo
#    dashboard/dados.js a partir da planilha .xlsx.
#  - A pasta de origem deve ter a estrutura esperada do projeto,
#    incluindo dashboard/index.html.
#
#  USO
#    ./instalar_macos.sh              -> instala em $HOME/Dashboard Leds Urbs
#    ./instalar_macos.sh "/outra/pasta"
#
#  DESINSTALACAO
#  Execute o arquivo desinstalar.sh que fica na pasta instalada.
# ======================================================================

ORIGEM="$(cd "$(dirname "$0")" && pwd)/"
DESTINO="${1:-$HOME/Dashboard Leds Urbs}"

echo "======================================================================"
echo "  Instalador - Dashboard Leds Urbs"
echo "======================================================================"
echo
echo "  Pasta de origem : $ORIGEM"
echo "  Pasta de destino: $DESTINO"
echo
printf "Instalar nesse local? [Enter para confirmar / N para digitar outro] -> "
read CONFIRMA || true
if [ "$CONFIRMA" = "N" ] || [ "$CONFIRMA" = "n" ]; then
  printf "Digite o caminho completo: "
  read DESTINO || true
  echo
fi

# ---------- 1. Copiar arquivos ----------
if [ "$ORIGEM" = "$DESTINO/" ]; then
  echo "[i] Origem e destino iguais - pulando a copia."
else
  echo "[+] Copiando arquivos..."
  mkdir -p "$DESTINO"
  cp -R "$ORIGEM". "$DESTINO" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "[ERR] Falha ao copiar arquivos para \"$DESTINO\"."
    printf "Pressione Enter para fechar..."; read _ || true
    exit 1
  fi
  echo "[+] Arquivos copiados para \"$DESTINO\"."
fi

if [ ! -f "$DESTINO/dashboard/index.html" ]; then
  echo "[ERR] Arquivo dashboard/index.html nao encontrado apos a copia."
  printf "Pressione Enter para fechar..."; read _ || true
  exit 1
fi

# ---------- 2. Python ----------
PY=""
if command -v python3 >/dev/null 2>&1; then
  PY="python3"
elif command -v python >/dev/null 2>&1; then
  PY="python"
fi

if [ -n "$PY" ]; then
  echo "[+] Python encontrado ($PY)."
  PY_OK=1
else
  PY_OK=0
  echo "[!] Python NAO encontrado."
  echo "    O dashboard funciona sem Python (basta abrir iniciar.sh ou o index.html)."
  echo "    Python so e necessario para regenerar dados.js a partir do .xlsx"
  echo "    (instale com:  xcode-select --install  ou baixe em https://www.python.org)."
fi

# ---------- 3. openpyxl ----------
if [ "$PY_OK" = "1" ]; then
  if "$PY" -c "import openpyxl" >/dev/null 2>&1; then
    echo "[+] openpyxl ja instalado."
  else
    echo "[~] Instalando openpyxl..."
    if "$PY" -m pip install openpyxl; then
      echo "[+] openpyxl instalado."
    else
      echo
      echo "[!] Falha ao instalar openpyxl (pip indisponivel)."
      echo "    Instale o Python de https://python.org (inclui o pip) ou:"
      echo "    /usr/bin/python3 -m ensurepip --upgrade   (apos xcode-select --install)"
      echo "    Depois rode:   $PY -m pip install openpyxl"
      echo "    O dashboard funciona sem openpyxl ate voce precisar regenerar dados.js."
      echo
    fi
  fi
fi

# ---------- 4. Atalhos no Desktop (.command) ----------
grep -q '^#!/bin/sh' "$DESTINO/iniciar.sh" && chmod +x "$DESTINO/iniciar.sh" "$DESTINO/atualizar.sh" "$DESTINO/desinstalar.sh"

DESK="$HOME/Desktop"
[ -d "$DESK" ] || mkdir -p "$DESK"

cat > "$DESK/Dashboard Leds Urbs.command" <<EOF
#!/bin/sh
cd "$DESTINO" || exit 1
exec ./iniciar.sh
EOF
chmod +x "$DESK/Dashboard Leds Urbs.command"

cat > "$DESK/Atualizar dados (Leds Urbs).command" <<EOF
#!/bin/sh
cd "$DESTINO" || exit 1
exec ./atualizar.sh
EOF
chmod +x "$DESK/Atualizar dados (Leds Urbs).command"

echo "[+] Atalhos criados no Desktop (.command)."
echo
echo "======================================================================"
echo "  Instalacao concluida!"
echo
echo "  Pasta          : $DESTINO"
echo "  Iniciar painel : atalho \"Dashboard Leds Urbs\" no Desktop"
echo "                   ou abra o Terminal e execute $DESTINO/iniciar.sh"
echo "  Atualizar dados: atalho \"Atualizar dados (Leds Urbs)\" no Desktop"
echo "  Desinstalar    : execute $DESTINO/desinstalar.sh"
echo "======================================================================"
echo
printf "Pressione Enter para fechar..."; read _ || true
exit 0