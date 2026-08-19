@echo off
rem ======================================================================
rem  DESINSTALADOR - Dashboard Leds Urbs
rem  Remove os atalhos da Area de Trabalho e apaga a pasta instalada.
rem
rem  ATENCAO: apaga permanentemente o conteudo desta pasta!
rem ======================================================================
setlocal
chcp 65001 >nul

title Desinstalar - Dashboard Leds Urbs

set "PASTA=%~dp0"
if "%PASTA:~-1%"=="\" set "PASTA=%PASTA:~0,-1%"

echo ======================================================================
echo   Desinstalar - Dashboard Leds Urbs
echo ======================================================================
echo.
echo   Pasta a remover: %PASTA%
echo.
set /p OK="Tem certeza? Digite SIM para confirmar: "
if /i not "%OK%"=="SIM" (
  echo   Cancelado.
  pause
  exit /b 0
)

rem ---------- Remover atalhos ----------
set "ATALHO_DIR=%USERPROFILE%\Desktop"
if not exist "%ATALHO_DIR%" set "ATALHO_DIR=%USERPROFILE%\OneDrive\Desktop"

echo [!] Removendo atalhos...
del /s /q "%ATALHO_DIR%\Dashboard Leds Urbs.lnk" >nul 2>&1
del /s /q "%ATALHO_DIR%\Atualizar dados (Leds Urbs).lnk" >nul 2>&1
echo [+] Atalhos removidos.

rem ---------- Apagar a pasta (com atraso p/ este script poder sair) ----------
cd /d "%TEMP%"
start "" /min cmd /c "timeout /t 2 /nobreak >nul & rmdir /s /q ""%PASTA%"""

echo [+] Removendo a pasta "%PASTA%"...
echo.
echo Desinstalacao concluida. Esta janela vai fechar.
timeout /t 3 /nobreak >nul
exit /b 0