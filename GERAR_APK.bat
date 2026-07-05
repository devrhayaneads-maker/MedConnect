@echo off
chcp 65001 >nul
title MedConnect - Gerador de APK
echo ============================================
echo   MedConnect - Gerando o APK do aplicativo
echo ============================================
echo.

echo [1/5] Criando a plataforma Android...
call flutter create . --platforms=android --project-name medconnect
if errorlevel 1 goto erro

echo.
echo [2/5] Baixando as dependencias...
call flutter pub get
if errorlevel 1 goto erro

echo.
echo [3/5] Aplicando o icone da empresa (logo MedConnect)...
call dart run flutter_launcher_icons
if errorlevel 1 goto erro

echo.
echo [4/5] Definindo o nome do app como "MedConnect"...
powershell -Command "$c = (Get-Content 'android/app/src/main/AndroidManifest.xml' -Raw) -replace 'android:label=\"[^\"]*\"', 'android:label=\"MedConnect\"'; Set-Content 'android/app/src/main/AndroidManifest.xml' -Value $c -NoNewline"
if errorlevel 1 goto erro

echo.
echo [5/5] Compilando o APK (essa etapa demora alguns minutos)...
call flutter build apk --release
if errorlevel 1 goto erro

echo.
echo ============================================
echo   PRONTO! O APK esta em:
echo   build\app\outputs\flutter-apk\app-release.apk
echo ============================================
start "" "build\app\outputs\flutter-apk"
pause
exit /b 0

:erro
echo.
echo ******************************************************
echo   Algo deu errado. Confira a mensagem acima.
echo   Dica: rode "flutter doctor" para ver se o Android
echo   SDK esta instalado (precisa do Android Studio).
echo ******************************************************
pause
exit /b 1
