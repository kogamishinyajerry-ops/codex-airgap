@echo off
rem ============================================================
rem  OpenCode 气隙环境验证脚本 (5 步)
rem  v6 精修 (2026-06-04): apiKey 改为从 opencode.json 动态读取,
rem  脱敏显示,不再硬编码,避免泄露真实凭据
rem ============================================================

chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

call :msg DEPLOY_BORDER
call :msg VERIFY_TITLE
call :msg VERIFY_SUBTITLE
call :msg DEPLOY_BORDER
echo.

set "PASS=0"
set "FAIL=0"

REM ---- 1. 二进制检查 ----
call :msg VERIFY_DEP_BIN
set "EXE=%~dp0bin\opencode.exe"
if exist "%EXE%" (
    for %%I in ("%EXE%") do echo       ^(%%~zI bytes^)
    call :msg VERIFY_DEP_BIN_OK
    set /a PASS+=1
) else (
    call :msg VERIFY_DEP_BIN_MISS
    set /a FAIL+=1
)
echo.

REM ---- 2. 配置检查 ----
call :msg VERIFY_DEP_CFG
set "CFG=%~dp0opencode.json"
if exist "%CFG%" (
    for %%I in ("%CFG%") do echo       ^(%%~zI bytes^)
    call :msg VERIFY_DEP_CFG_OK
    set /a PASS+=1
) else (
    call :msg VERIFY_DEP_CFG_MISS
    set /a FAIL+=1
)
echo.

REM ---- 3. API Key 检查 (脱敏, 从 opencode.json 动态读取) ----
call :msg VERIFY_DEP_KEY
if not exist "%CFG%" (
    call :msg VERIFY_DEP_CFG_MISS
    set /a FAIL+=1
    goto :SKIP_KEY
)
for /f "usebackq tokens=*" %%k in (`powershell -NoProfile -Command ^
    "$j = Get-Content -LiteralPath '%CFG%' -Raw -Encoding UTF8 | ConvertFrom-Json; $k = $j.provider.newapi.options.apiKey; if ($k) { Write-Output $k } else { Write-Output '__MISSING__' }"`) do set "API_KEY=%%k"
if "!API_KEY!"=="__MISSING__" (
    call :msg VERIFY_DEP_KEY_MISS
    set /a FAIL+=1
) else if "!API_KEY!"=="<YOUR_NEWAPI_KEY>" (
    call :msg VERIFY_DEP_KEY_PLACE
    set /a FAIL+=1
) else (
    set "KEY_HEAD=!API_KEY:~0,8!"
    call :msg VERIFY_DEP_KEY_OK
    echo       !KEY_HEAD!
    call :msg VERIFY_DEP_KEY_SUFFIX
    set /a PASS+=1
)
:SKIP_KEY
echo.

REM ---- 4. 外网隔离验证 ----
call :msg VERIFY_NET
powershell -NoProfile -Command ^
  "try { $r = Invoke-WebRequest -Uri 'https://github.com/' -UseBasicParsing -TimeoutSec 3 -Method HEAD -ErrorAction Stop; Write-Host '       [WARN] 仍能访问 github.com,可能不在气隙环境' } catch { Write-Host '       [OK] 外网不可达 (符合气隙部署)' }"
echo.

REM ---- 5. 真实鉴权 + 模型测试 ----
call :msg VERIFY_AUTH
call :msg VERIFY_AUTH_TARGET
echo         http://10.136.232.50/v1/chat/completions
echo         model: GLM-5.1-AWQ-4bit
if not defined API_KEY goto :SKIP_AUTH
if "!API_KEY!"=="<YOUR_NEWAPI_KEY>" goto :SKIP_AUTH
if "!API_KEY!"=="__MISSING__" goto :SKIP_AUTH

set "AUTH_CODE="
for /f "tokens=*" %%a in ('curl -s -o nul -w "%%{http_code}" --max-time 15 -X POST -H "Content-Type: application/json" -H "Authorization: Bearer !API_KEY!" -d "{\"model\":\"GLM-5.1-AWQ-4bit\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}],\"max_tokens\":1}" "http://10.136.232.50/v1/chat/completions" 2^>^&1') do set "AUTH_CODE=%%a"
echo         HTTP code: !AUTH_CODE!
if "!AUTH_CODE!"=="200" (
    call :msg VERIFY_AUTH_OK
    set /a PASS+=1
) else if "!AUTH_CODE!"=="401" (
    call :msg VERIFY_AUTH_401
    set /a FAIL+=1
) else if "!AUTH_CODE!"=="403" (
    call :msg VERIFY_AUTH_403
    set /a FAIL+=1
) else if "!AUTH_CODE!"=="404" (
    call :msg VERIFY_AUTH_404
    set /a FAIL+=1
) else if "!AUTH_CODE!"=="400" (
    call :msg VERIFY_AUTH_400
    set /a FAIL+=1
) else if "!AUTH_CODE!"=="000" (
    call :msg VERIFY_AUTH_000
) else (
    call :msg VERIFY_AUTH_OTH
    set /a FAIL+=1
)
:SKIP_AUTH
echo.

call :msg DEPLOY_BORDER
call :msg VERIFY_RESULT
echo         !PASS!
call :msg VERIFY_RESULT_FAIL
echo         !FAIL!
call :msg DEPLOY_BORDER

REM 清理: API Key 变量 (内存保护, 防 dump)
set "API_KEY="
set "KEY_HEAD="

if !FAIL! gtr 0 (
    call :msg VERIFY_SUMMARY_FAIL
    echo         !FAIL!
    call :msg VERIFY_SUMMARY_FAIL_END
    pause
    exit /b 1
)
call :msg VERIFY_SUMMARY_PASS
pause
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
