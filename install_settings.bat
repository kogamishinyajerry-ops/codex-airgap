@echo off
rem ============================================================
rem  Install opencode.json to User Config Directory
rem  Target: %USERPROFILE%\.config\opencode\opencode.json
rem  Generated: 2026-06-04
rem ============================================================

setlocal EnableExtensions

set "SRC=%~dp0opencode.json"
set "DST_DIR=%USERPROFILE%\.config\opencode"
set "DST=%DST_DIR%\opencode.json"

if not exist "%SRC%" (
    echo [FATAL] Source opencode.json not found in %~dp0
    pause
    exit /b 1
)

if not exist "%DST_DIR%" (
    echo Creating %DST_DIR% ...
    mkdir "%DST_DIR%"
    if errorlevel 1 (
        echo [FATAL] Failed to create %DST_DIR%
        pause
        exit /b 1
    )
)

echo Copying opencode.json to %DST% ...
copy /Y "%SRC%" "%DST%" >nul
if errorlevel 1 (
    echo [FATAL] Copy failed.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  opencode.json installed to %DST%
echo  OpenCode (global) will now use this config by default.
echo ============================================================
echo.
pause

endlocal
