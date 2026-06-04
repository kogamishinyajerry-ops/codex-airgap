@echo off
rem ============================================================
rem  OpenCode 依赖一键安装脚本
rem  v6 精修 (2026-06-04): OpenCode 是单 exe, 只需 VC++ Redist
rem ============================================================

chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

call :msg DEPLOY_BORDER
call :msg DEPS_TITLE
call :msg DEPLOY_BORDER
echo.
call :msg DEPS_INTRO
echo         1. VC++ 2015-2022 Redistributable (x64)
echo         2. PowerShell 5.1+ (Windows 10/11 自带)
echo.

REM ---- 1. VC++ Redist 检测 + 安装 ----
call :msg DEPS_VC_HEADER
call :msg DEPS_VC_NOTE
echo.

reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" >nul 2>nul
if %ERRORLEVEL%==0 (
    call :msg DEPS_VC_OK
    goto :SKIP_VC
)

set "VCREDIST=%~dp0dependencies\vc_redist.x64.exe"
if not exist "%VCREDIST%" (
    call :msg DEPS_VC_SKIP
    call :msg DEPS_VC_MAY_MANUAL
    goto :SKIP_VC
)

call :msg DEPS_VC_RUN
"%VCREDIST%" /install /quiet /norestart
if errorlevel 1 (
    call :msg DEPS_VC_WARN
    call :msg DEPS_VC_MAY_MANUAL
) else (
    call :msg DEPS_VC_OK
)
:SKIP_VC
echo.

REM ---- 2. PowerShell 检测 ----
call :msg DEPS_POWERSHELL_HEADER
call :msg DEPS_POWERSHELL_RUN
where powershell >nul 2>nul
if %ERRORLEVEL%==0 (
    call :msg DEPS_POWERSHELL_OK
) else (
    call :msg DEPS_POWERSHELL_FAIL
)
echo.

call :msg DEPLOY_BORDER
call :msg DEPS_DONE
call :msg DEPLOY_BORDER
echo.
call :msg DEPS_DONE_NEXT
echo.
call :msg PRESS_ANY_KEY
pause >nul
exit /b 0


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
