@echo off
setlocal enabledelayedexpansion
echo [DEBUG] Start trigger_actions.bat

REM Configurações do repositório
set "OWNER=bioadsl"
set "REPO=test_backend"
set "WORKFLOW=newman.yml"
set "REF=main"
set "TOKEN="
echo [DEBUG] Vars set: OWNER=%OWNER% REPO=%REPO% REF=%REF%

REM Token pelo argumento
echo [DEBUG] Checking arg token
if not "%~1"=="" set "TOKEN=%~1"
echo [DEBUG] After arg: TOKEN=%TOKEN%

REM Token pela variável de ambiente
echo [DEBUG] Checking env token
if not defined TOKEN if not "%GITHUB_TOKEN%"=="" set "TOKEN=%GITHUB_TOKEN%"
echo [DEBUG] After env: TOKEN=%TOKEN%

REM Se nao houver token ainda, tentar carregar de arquivo local .env.github (nao versionado)
echo [DEBUG] Checking .env.github
if not defined TOKEN if exist ".env.github" call :readEnvToken
echo [DEBUG] After .env: TOKEN=%TOKEN%

echo [DEBUG] Before API block, TOKEN defined? %TOKEN%
if defined TOKEN call :dispatchApi
echo [INFO] Nenhum token informado. Usando fallback por push com commit vazio...

REM Fallback: acionar por push com commit vazio
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [ERRO] Este diretório nao é um repositório git.
  exit /b 1
)
git commit --allow-empty -m "Trigger CI via batch" >nul 2>&1
git push origin %REF%
set EXITCODE=%ERRORLEVEL%
if %EXITCODE% EQU 0 goto push_success
echo [ERRO] Falha ao fazer push (codigo %EXITCODE%).
exit /b %EXITCODE%

goto :eof

:dispatchApi
echo [INFO] Disparando workflow via API (workflow_dispatch)...
> payload.json echo {"ref":"%REF%"}
curl.exe -s -L -X POST ^
  -H "Accept: application/vnd.github+json" ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "X-GitHub-Api-Version: 2022-11-28" ^
  --data @payload.json ^
  -o dispatch_response.json ^
  -w "%{http_code}" ^
  https://api.github.com/repos/%OWNER%/%REPO%/actions/workflows/%WORKFLOW%/dispatches > http_code.txt

set /p HTTP=<http_code.txt
del payload.json 2>nul
del http_code.txt 2>nul
if "%HTTP%"=="204" goto api_success
echo [WARN] API retornou HTTP %HTTP%. Tentando commit vazio...
exit /b

:api_success
echo [OK] Workflow acionado via API.
exit /b 0

:readEnvToken
for /f "usebackq tokens=1,* delims==" %%A in (".env.github") do (
  if /I "%%~A"=="GITHUB_TOKEN" set "TOKEN=%%~B"
)
exit /b

:push_success
echo [OK] Workflow acionado via push.
exit /b 0