@echo off
rem ============================================================
rem  OpenCode v1.15.13 - Air-Gapped Launcher
rem  Generated: 2026-06-04
rem  Model:    GLM-5.1-AWQ-4bit via New API
rem  Source:   https://github.com/anomalyco/opencode
rem ============================================================

setlocal EnableExtensions

rem Lock configuration to local file (no remote lookup)
set "OPENCODE_CONFIG=%~dp0opencode.json"

rem Verify binary
set "EXE=%~dp0bin\opencode.exe"
if not exist "%EXE%" (
    echo [FATAL] bin\opencode.exe not found.
    echo Run setup.bat first.
    pause
    exit /b 1
)

rem Verify config
if not exist "%OPENCODE_CONFIG%" (
    echo [FATAL] opencode.json not found in %~dp0
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  OpenCode v1.15.13 - New API
echo  Model:  newapi/GLM-5.1-AWQ-4bit
echo  Base:   http://10.136.232.50/v1
echo ============================================================
echo.

"%EXE%" %*

endlocal
