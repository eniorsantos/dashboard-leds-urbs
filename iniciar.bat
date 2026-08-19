@echo off
rem Inicia um servidor local e abre o dashboard no navegador.
rem Necessario para o Google Sheets ser aceito (CORS): abrindo o
rem index.html direto (file://) o Google bloqueia com "Failed to fetch".
cd /d "%~dp0"
echo --------------------------------------------------------------------
echo  Servidor do dashboard:  http://localhost:8000/dashboard/
echo  Abrindo no navegador...
echo  Para parar: feche esta janela ou pressione Ctrl+C.
echo --------------------------------------------------------------------
start "" http://localhost:8000/dashboard/
python servidor.py
if errorlevel 1 (
  echo.
  echo Falhou ao iniciar o servidor - verifique se o Python esta instalado.
)
pause