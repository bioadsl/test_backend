@echo off
setlocal enabledelayedexpansion

REM Configurações do repositório
set OWNER=bioadsl
set REPO=test_backend
set WORKFLOW=newman.yml
set REF=main

REM Token pode ser passado como argumento ou via variável de ambiente GITHUB_TOKEN
if not "%~1"=="" (
  set TOKEN=%~1
) else if not "%GITHUB_TOKEN%"=="" (
  set TOKEN=%GITHUB_TOKEN%
)

REM Se nao houver token ainda, tentar carregar de arquivo local .env.github (nao versionado)
if "%TOKEN%"=="" if exist ".env.github" (
  for /f "usebackq tokens=1,2 delims==" %%A in (".env.github") do (
    if /I "%%A"=="GITHUB_TOKEN" set TOKEN=%%B
  )
)

if not "%TOKEN%"=="" (
  echo [INFO] Disparando workflow via API (workflow_dispatch)...
  > payload.json echo {"ref":"%REF%"}
  curl -s -L -X POST ^
    -H "Accept: application/vnd.github+json" ^
    -H "Authorization: Bearer %TOKEN%" ^
    -H "X-GitHub-Api-Version: 2022-11-28" ^
    --data @payload.json ^
    https://api.github.com/repos/%OWNER%/%REPO%/actions/workflows/%WORKFLOW%/dispatches

  set EXITCODE=%ERRORLEVEL%
  del payload.json 2>nul
  if %EXITCODE% EQU 0 (
    echo [OK] Workflow acionado via API.
    exit /b 0
  ) else (
    echo [WARN] Falha ao acionar via API (codigo %EXITCODE%). Tentando commit vazio...
  )
) else (
  echo [INFO] Nenhum token informado. Usando fallback por push com commit vazio...
)

REM Fallback: acionar por push com commit vazio
git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo [ERRO] Este diretório nao é um repositório git.
  exit /b 1
)
git commit --allow-empty -m "Trigger CI via batch" >nul 2>&1
git push origin %REF%
set EXITCODE=%ERRORLEVEL%
if %EXITCODE% EQU 0 (
  echo [OK] Workflow acionado via push.
  exit /b 0
) else (
  echo [ERRO] Falha ao fazer push (codigo %EXITCODE%).
  exit /b %EXITCODE%
)