@echo off
rem ============================================================
rem  OpenCode v1.15.13 - First-Time Setup
rem  v6 精修 (2026-06-04): 7 步 + VC++ 探测 + 外网隔离验证
rem  中文文案外置 messages\zh.txt,避免编码坑
rem ============================================================

chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

call :msg DEPLOY_BORDER
call :msg DEPLOY_TITLE
call :msg DEPLOY_SUBTITLE
call :msg DEPLOY_BORDER
echo.
call :msg SETUP_TARGET
call :msg SETUP_MODEL
echo.

REM ---- 0. 探测 VC++ 2015-2022 Redistributable (x64) ----
call :msg SETUP_INFO_VC
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" >nul 2>nul
if %ERRORLEVEL%==0 (
    call :msg SETUP_VC_OK
) else (
    call :msg SETUP_VC_WARN
)
echo.

REM ---- 1. 解压 opencode.exe ----
call :msg STEP1_HEADER
set "EXE=%~dp0bin\opencode.exe"
set "ZIP=%~dp0downloads\opencode-windows-x64.zip"
if exist "%EXE%" (
    call :msg STEP1_SKIP
) else (
    if not exist "%ZIP%" (
        call :msg STEP1_FATAL_ZIP
        pause
        exit /b 1
    )
    if not exist "%~dp0bin" mkdir "%~dp0bin"
    powershell -NoProfile -Command "Expand-Archive -LiteralPath '%ZIP%' -DestinationPath '%~dp0bin' -Force"
    if errorlevel 1 (
        call :msg STEP1_FATAL_EXTRACT
        pause
        exit /b 1
    )
    call :msg STEP1_OK
)
echo.

REM ---- 2. SHA256 校验 ----
call :msg STEP2_HEADER
set "EXPECTED_SHA256=d102e1df3ef1617c6d03211c8a5ca10798f9552887d50ca10040468b667edae8"
set "ACTUAL_SHA256="
for /f "skip=1 tokens=* delims= " %%a in ('certutil -hashfile "%EXE%" SHA256 ^| findstr /v "hash certutil"') do (
    if not defined ACTUAL_SHA256 set "ACTUAL_SHA256=%%a"
)
if /i "!ACTUAL_SHA256!"=="%EXPECTED_SHA256%" (
    call :msg STEP2_OK
) else (
    call :msg STEP2_WARN
    call :msg STEP2_EXPECTED
    echo         %EXPECTED_SHA256%
    call :msg STEP2_ACTUAL
    echo         !ACTUAL_SHA256!
)
echo.

REM ---- 3. 检查 opencode.json ----
call :msg STEP3_HEADER
set "CFG=%~dp0opencode.json"
if not exist "%CFG%" (
    call :msg STEP3_FATAL
    call :msg STEP3_HINT
    pause
    exit /b 1
)
call :msg STEP3_OK
echo.

REM ---- 4. 验证 New API 连通 (内网) ----
call :msg STEP4_HEADER
call :msg STEP4_TARGET
echo         http://10.136.232.50/v1/models
set "HTTP_CODE="
for /f "tokens=*" %%a in ('curl -s -o nul -w "%%{http_code}" --max-time 10 "http://10.136.232.50/v1/models" 2^>^&1') do set "HTTP_CODE=%%a"
echo         HTTP code: !HTTP_CODE!
if "!HTTP_CODE!"=="200" (
    call :msg STEP4_OK
) else if "!HTTP_CODE!"=="401" (
    call :msg STEP4_WARN_401
) else if "!HTTP_CODE!"=="403" (
    call :msg STEP4_WARN_403
) else if "!HTTP_CODE!"=="404" (
    call :msg STEP4_WARN_404
) else if "!HTTP_CODE!"=="000" (
    call :msg STEP4_WARN_000
) else (
    call :msg STEP4_WARN_OTH
)
echo.

REM ---- 5. opencode.exe 首次测试 ----
call :msg STEP5_HEADER
"%EXE%" --version
if errorlevel 1 (
    call :msg STEP5_FATAL
    pause
    exit /b 1
)
call :msg STEP5_OK
echo.

REM ---- 6. 验证外网已隔离 (气隙核心保障) ----
call :msg STEP6_HEADER
call :msg STEP6_PROBE
powershell -NoProfile -Command ^
  "try { $r = Invoke-WebRequest -Uri 'https://github.com/' -UseBasicParsing -TimeoutSec 3 -Method HEAD -ErrorAction Stop; Write-Host '       [WARN] 仍能访问 github.com,可能不在气隙环境' } catch { Write-Host '       [OK] 外网已隔离 (符合气隙部署预期)' }"
echo.

REM ---- 7. 部署完成 ----
call :msg DEPLOY_BORDER
call :msg STEP7_DONE
call :msg DEPLOY_BORDER
echo.
call :msg STEP7_NEXT_HINT1
call :msg STEP7_NEXT_HINT2
call :msg STEP7_NEXT_HINT3
call :msg STEP7_NEXT_HINT4
echo.
call :msg STEP7_NEXT_NOTE
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
