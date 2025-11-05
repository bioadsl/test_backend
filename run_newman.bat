@echo off
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