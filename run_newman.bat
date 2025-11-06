@echo off
REM Executa Newman focando na pasta "Books Flow" e exporta relatório JSON
SETLOCAL ENABLEDELAYEDEXPANSION
CD /D "%~dp0"

SET COLLECTION=postman_collection.json
SET ENV=postman_environment.json
SET FOLDER=Books Flow
SET REPORT_DIR=reports
SET JSON_REPORT=%REPORT_DIR%\newman_report.json

IF NOT EXIST "%COLLECTION%" (
  ECHO [ERRO] Arquivo de coleção não encontrado: %COLLECTION%
  EXIT /B 1
)
IF NOT EXIST "%ENV%" (
  ECHO [ERRO] Arquivo de ambiente não encontrado: %ENV%
  EXIT /B 1
)

IF NOT EXIST "%REPORT_DIR%" (
  MKDIR "%REPORT_DIR%"
)

ECHO [INFO] Rodando coleção: %COLLECTION% ^| Pasta: "%FOLDER%" ^| Ambiente: %ENV%
ECHO [INFO] Gerando relatório JSON em: %JSON_REPORT%

REM Usa npx para localizar o newman instalado localmente
npx newman run "%COLLECTION%" -e "%ENV%" --folder "%FOLDER%" -r cli,json,htmlextra --reporter-json-export "%JSON_REPORT%" --reporter-htmlextra-export "%REPORT_DIR%\newman_report.html"
IF %ERRORLEVEL% NEQ 0 (
  ECHO [ERRO] Execução do Newman falhou com código %ERRORLEVEL%
  EXIT /B %ERRORLEVEL%
)

ECHO [SUCESSO] Execução concluída.
ECHO [SUCESSO] JSON: %JSON_REPORT%
ECHO [SUCESSO] HTML: %REPORT_DIR%\newman_report.html
ENDLOCAL
EXIT /B 0
setlocal EnableExtensions

REM Usage: run_newman.bat [collection.json] [environment.json] [reporters]
REM Defaults: postman_collection.json, postman_environment.json, cli

set "COLLECTION=%~1"
set "ENVIRONMENT=%~2"
set "REPORTERS=%~3"

if "%COLLECTION%"=="" set "COLLECTION=postman_collection.json"
if "%ENVIRONMENT%"=="" set "ENVIRONMENT=postman_environment.json"
if "%REPORTERS%"=="" set "REPORTERS=cli"

if not exist "%COLLECTION%" (
  echo [ERROR] Collection file "%COLLECTION%" not found.
  exit /b 1
)

if not exist "%ENVIRONMENT%" (
  echo [ERROR] Environment file "%ENVIRONMENT%" not found.
  exit /b 1
)

echo Running: npx newman run "%COLLECTION%" -e "%ENVIRONMENT%" -r %REPORTERS%
npx newman run "%COLLECTION%" -e "%ENVIRONMENT%" -r %REPORTERS%
set "EXITCODE=%ERRORLEVEL%"

if not "%EXITCODE%"=="0" (
  echo [ERROR] Newman exited with code %EXITCODE%
)

exit /b %EXITCODE%