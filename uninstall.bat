@echo off
rem ============================================================
rem  OpenCode 卸载脚本
rem  v6 精修 (2026-06-04): 二次确认 + 列出删除项 + 完整撤回
rem ============================================================

chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"

call :msg DEPLOY_BORDER
call :msg UNINSTALL_TITLE
call :msg DEPLOY_BORDER
echo.
call :msg UNINSTALL_LIST_HEADER
call :msg UNINSTALL_LIST_1
call :msg UNINSTALL_LIST_2
echo.
call :msg UNINSTALL_CONFIRM
set /p "CONFIRM="
if /i not "%CONFIRM%"=="YES" (
    call :msg UNINSTALL_CANCEL
    pause
    exit /b 0
)

echo.
call :msg UNINSTALL_REMOVING
echo         %~dp0bin\opencode.exe
if exist "%~dp0bin\opencode.exe" del /F /Q "%~dp0bin\opencode.exe" >nul 2>&1

set "DST=%USERPROFILE%\.config\opencode\opencode.json"
call :msg UNINSTALL_REMOVING
echo         %DST%
if exist "%DST%" del /F /Q "%DST%" >nul 2>&1

echo.
call :msg DEPLOY_BORDER
call :msg UNINSTALL_OK
call :msg DEPLOY_BORDER
echo.
call :msg UNINSTALL_DONE
call :msg UNINSTALL_REINSTALL
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
