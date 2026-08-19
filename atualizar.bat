@echo off
rem Atualiza os dados do dashboard a partir da planilha "Leds Urbs" (Downloads ou Documents).
cd /d "%~dp0"
python atualizar_dados.py
if %errorlevel% == 0 (
  echo.
  echo Pronto! Abra o arquivo dashboard\index.html no navegador.
) else (
  echo.
  echo Falhou - verifique se o Python esta instalado e com openpyxl:  pip install openpyxl
)
pause