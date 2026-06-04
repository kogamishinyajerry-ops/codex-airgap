@echo off
rem ============================================================
rem  Install opencode.json to User Config Directory
rem  v6 精修 (2026-06-04): 用 :msg 调用, 失败/成功日志分开
rem ============================================================

chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"

set "SRC=%~dp0opencode.json"
set "DST_DIR=%USERPROFILE%\.config\opencode"
set "DST=%DST_DIR%\opencode.json"

call :msg DEPLOY_BORDER
call :msg SETTINGS_TITLE
call :msg DEPLOY_BORDER
call :msg SETTINGS_TARGET
echo.
call :msg SETTINGS_INFO_SRC
echo         %SRC%
echo.

if not exist "%SRC%" (
    call :msg SETTINGS_FAIL_SRC
    pause
    exit /b 1
)

if not exist "%DST_DIR%" (
    call :msg SETTINGS_MKDIR
    echo         %DST_DIR%
    mkdir "%DST_DIR%"
    if errorlevel 1 (
        echo [FATAL] 目录创建失败
        pause
        exit /b 1
    )
)

echo Copying opencode.json to %DST% ...
copy /Y "%SRC%" "%DST%" >nul
if errorlevel 1 (
    call :msg SETTINGS_COPY_FAIL
    pause
    exit /b 1
)

call :msg SETTINGS_COPY_OK
echo.
call :msg SETTINGS_NOTE1
call :msg SETTINGS_NOTE2
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
