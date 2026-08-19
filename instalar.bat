@echo off
rem ======================================================================
rem  INSTALADOR - Dashboard Leds Urbs
rem ======================================================================
rem
rem  O QUE FAZ
rem  Copia este projeto para uma pasta permanente fora da pasta do
rem  instalador, verifica a instalacao do Python e do modulo openpyxl,
rem  instala o openpyxl se faltar e cria atalhos na Area de Trabalho
rem  para abrir o painel e atualizar os dados.
rem
rem  REQUISITOS
rem  - Windows (todas as versoes suportadas por este script).
rem  - Python e opcional: o painel funciona sem ele. O Python e
rem    necessario apenas para Atualizar dados, que regenera o arquivo
rem    dashboard\dados.js a partir da planilha .xlsx.
rem  - A pasta de origem deve ter a estrutura esperada do projeto,
rem    incluindo dashboard\index.html.
rem
rem  USO
rem    Duplo clique em instalar.bat
rem        -> instala em %USERPROFILE%\Dashboard Leds Urbs
rem    instalar.bat "C:\Outra\Pasta"  (no prompt do CMD ou PowerShell)
rem        -> instala no caminho informado
rem
rem  PASSOS EXECUTADOS
rem    1. Mostra a pasta de destino e pede confirmacao; permite
rem       digitar outro caminho (resposta "N").
rem    2. Copia os arquivos para o destino (pula se for a mesma pasta).
rem       Confere se dashboard\index.html foi copiado.
rem    3. Detecta o Python (python --version). Se ausente, avisa que o
rem       painel continua funcionando sem ele.
rem    4. Se o Python existir, confere se openpyxl esta instalado e
rem       instala com "python -m pip install openpyxl" se faltar.
rem    5. Cria 2 atalhos na Area de Trabalho:
rem         - "Dashboard Leds Urbs"         -> abre o painel
rem         - "Atualizar dados (Leds Urbs)" -> regenera dados.js
rem       (usa OneDrive\Desktop se a pasta Desktop padrao nao existir)
rem    6. Mostra resumo final com a pasta instalada.
rem
rem  DESINSTALACAO
rem  Execute o arquivo desinstalar.bat que fica na pasta de destino.
rem
rem  OBSERVACOES
rem  - Os atalhos apontam para a pasta de destino; nao a mova depois
rem    da instalacao, senao os atalhos quebram.
rem  - A pasta de origem pode ser removida apos instalar; o projeto
rem    instalado fica independente.
rem  - Nao feche a janela durante a copia dos arquivos.
rem ======================================================================
setlocal enabledelayedexpansion
chcp 65001 >nul

title Instalador - Dashboard Leds Urbs

echo ======================================================================
echo   Instalador - Dashboard Leds Urbs
echo ======================================================================
echo.

set "ORIGEM=%~dp0"

rem ---------- Pasta de destino ----------
set "DESTINO=%1"
if "%DESTINO%"=="" set "DESTINO=%USERPROFILE%\Dashboard Leds Urbs"

echo   Pasta de origem : %ORIGEM%
echo   Pasta de destino: %DESTINO%
echo.
set /p CONFIRMA="Instalar nesse local? [Enter para confirmar / N para digitar outro] -> "
if /i "%CONFIRMA%"=="N" (
  set /p DESTINO="Digite o caminho completo: "
  echo.
)

rem ---------- 1. Copiar arquivos ----------
if /i "%ORIGEM%" neq "%DESTINO%\" (
  echo [+] Copiando arquivos...
  if not exist "%DESTINO%" mkdir "%DESTINO%"
  xcopy /E /I /Y "%ORIGEM%"*.* "%DESTINO%" >nul
  if errorlevel 1 (
    echo [ERR] Falha ao copiar arquivos para "%DESTINO%".
    pause
    exit /b 1
  )
  echo [+] Arquivos copiados para "%DESTINO%".
) else (
  echo [i] Origem e destino iguais - pulando a copia.
)

if not exist "%DESTINO%\dashboard\index.html" (
  echo [ERR] Arquivo dashboard\index.html nao encontrado apos a copia.
  pause
  exit /b 1
)

echo.

rem ---------- 2. Python ----------
set "PYTHON_OK="
python --version >nul 2>&1
if %errorlevel%==0 (
  set "PYTHON_OK=1"
  echo [+] Python encontrado.
) else (
  echo [!] Python NAO encontrado.
  echo     O dashboard funciona sem Python ^(basta abrir iniciar.bat ou o index.html^).
  echo     Python so e necessario para regenerar dados.js a partir do .xlsx
  echo         ^(instale em https://www.python.org/downloads/ e marque "Add to PATH"^).
)

rem ---------- 3. openpyxl ----------
if defined PYTHON_OK (
  python -c "import openpyxl" >nul 2>&1
  if !errorlevel!==0 (
    echo [+] openpyxl ja instalado.
  ) else (
    echo [~] Instalando openpyxl...
    python -m pip install openpyxl
  )
)

echo.

rem ---------- 4. Atalhos na Area de Trabalho ----------
set "ATALHO_DIR=%USERPROFILE%\Desktop"
if not exist "%ATALHO_DIR%" set "ATALHO_DIR=%USERPROFILE%\OneDrive\Desktop"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ws=New-Object -ComObject WScript.Shell;"^
  "$i1=$ws.CreateShortcut('%ATALHO_DIR%\Dashboard Leds Urbs.lnk');"^
  "$i1.TargetPath='%DESTINO%\iniciar.bat';"^
  "$i1.WorkingDirectory='%DESTINO%';"^
  "$i1.Description='Abre o painel de programacao das telas de LED';"^
  "$i1.Save();"^
  "$i2=$ws.CreateShortcut('%ATALHO_DIR%\Atualizar dados (Leds Urbs).lnk');"^
  "$i2.TargetPath='%DESTINO%\atualizar.bat';"^
  "$i2.WorkingDirectory='%DESTINO%';"^
  "$i2.Description='Atualiza os dados a partir da planilha de Downloads/Documents';"^
  "$i2.Save()"
if errorlevel 1 (
  echo [!] Nao foi possivel criar os atalhos ^(ignore se nao quiser atalhos^).
) else (
  echo [+] Atalhos criados na Area de Trabalho.
)

echo.
echo ======================================================================
echo   Instalacao concluida!
echo.
echo   Pasta          : %DESTINO%
echo   Iniciar painel : atalho "Dashboard Leds Urbs" na Area de Trabalho
echo                    ou execute "%DESTINO%\iniciar.bat"
echo   Atualizar dados: atalho "Atualizar dados (Leds Urbs)"
echo   Desinstalar    : execute "%DESTINO%\desinstalar.bat"
echo ======================================================================
echo.
pause