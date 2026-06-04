@echo off
rem ============================================================
rem  OpenCode v1.15.13 - Air-Gapped Launcher
rem  v6 精修 (2026-06-04): 锁配置 + 强制隔离 + 读 model 显示
rem  唯一官方支持的环境变量: OPENCODE_CONFIG (锁本地配置)
rem ============================================================

chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

call :msg DEPLOY_BORDER
call :msg RUN_TITLE
call :msg RUN_SUBTITLE
call :msg DEPLOY_BORDER
echo.

REM ---- 1. 检查二进制 ----
set "EXE=%~dp0bin\opencode.exe"
if not exist "%EXE%" (
    call :msg RUN_FATAL_EXE
    pause
    exit /b 1
)

REM ---- 2. 检查配置 ----
set "CFG=%~dp0opencode.json"
if not exist "%CFG%" (
    call :msg RUN_FATAL_CFG
    pause
    exit /b 1
)

REM ---- 3. 解析 model 名 + baseURL (用于显示) ----
for /f "usebackq tokens=*" %%m in (`powershell -NoProfile -Command ^
    "$j = Get-Content -LiteralPath '%CFG%' -Raw -Encoding UTF8 | ConvertFrom-Json; Write-Output $j.model"`) do set "MODEL_NAME=%%m"
for /f "usebackq tokens=*" %%b in (`powershell -NoProfile -Command ^
    "$j = Get-Content -LiteralPath '%CFG%' -Raw -Encoding UTF8 | ConvertFrom-Json; Write-Output $j.provider.newapi.options.baseURL"`) do set "BASE_URL=%%b"

call :msg RUN_INFO_BASE
echo         %CFG%
call :msg RUN_INFO_MODEL
echo         !MODEL_NAME!
call :msg DEPLOY_BORDER2
echo         baseURL: !BASE_URL!
call :msg DEPLOY_BORDER2
echo.

REM ---- 4. 锁配置到本地 (防远程查找 + 防 OpenCode 自动更新检查) ----
set "OPENCODE_CONFIG=%CFG%"

REM 禁用可能的遥测 (虽然 OpenCode 文档未明说支持, 设了无害)
set "OPENCODE_DISABLE_TELEMETRY=1"
set "DO_NOT_TRACK=1"
set "NO_COLOR=1"

call :msg RUN_INFO_ISOLATE
echo.

call :msg RUN_LAUNCH
echo.

REM ---- 5. 启动 ----
"%EXE%" %*

endlocal
goto :eof


REM ===== Sub: print message line from messages\zh.txt by [LABEL] =====
:msg
setlocal
for /f "tokens=1* delims=]" %%a in ('findstr /B /C:"[%~1]" "messages\zh.txt" 2^>nul') do (
    endlocal
    echo %%b
    goto :eof
)
endlocal
goto :eof
