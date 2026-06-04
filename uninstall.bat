@echo off
rem ============================================================
rem  OpenCode Uninstaller
rem  Removes: bin\, opencode.json (user config), settings
rem  Keeps: downloads\ (zip), docs\, messages\
rem  Generated: 2026-06-04
rem ============================================================

setlocal EnableExtensions

echo.
echo ============================================================
echo  OpenCode Uninstaller
echo  This will remove:
echo    1. bin\opencode.exe
echo    2. %USERPROFILE%\.config\opencode\opencode.json
echo ============================================================
echo.

set /p "CONFIRM=Type YES to confirm uninstallation: "
if /i not "%CONFIRM%"=="YES" (
    echo Cancelled.
    pause
    exit /b 0
)

rem --- Remove binary ---
set "EXE=%~dp0bin\opencode.exe"
if exist "%EXE%" (
    echo Removing %EXE% ...
    del /F /Q "%EXE%" >nul 2>&1
)

rem --- Remove user config ---
set "DST=%USERPROFILE%\.config\opencode\opencode.json"
if exist "%DST%" (
    echo Removing %DST% ...
    del /F /Q "%DST%" >nul 2>&1
)

echo.
echo ============================================================
echo  Uninstallation complete.
echo  Run setup.bat to re-install.
echo ============================================================
echo.
pause

endlocal
