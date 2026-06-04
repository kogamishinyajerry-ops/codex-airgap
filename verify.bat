@echo off
rem ============================================================
rem  OpenCode Connectivity Verifier
rem  Generated: 2026-06-04
rem ============================================================

setlocal EnableExtensions EnableDelayedExpansion

set "BASE_URL=http://10.136.232.50/v1"
set "MODEL=GLM-5.1-AWQ-4bit"
set "API_KEY=sk-th0kH9e9N4qWOsZPFp0PCqsG4Ho9k6Yiehfv4gcJPYbwH2K0"

echo.
echo ============================================================
echo  OpenCode Connectivity Check
echo  Target: %BASE_URL%
echo  Model:  %MODEL%
echo ============================================================
echo.

rem --- 1. Binary present ---
echo [1/5] Binary check ...
set "EXE=%~dp0bin\opencode.exe"
if exist "%EXE%" (
    for %%I in ("%EXE%") do echo   - bin\opencode.exe: %%~zI bytes
) else (
    echo   [FATAL] bin\opencode.exe missing.
    goto :END_FAIL
)
echo.

rem --- 2. Config present ---
echo [2/5] Config check ...
set "CFG=%~dp0opencode.json"
if exist "%CFG%" (
    for %%I in ("%CFG%") do echo   - opencode.json: %%~zI bytes
) else (
    echo   [FATAL] opencode.json missing.
    goto :END_FAIL
)
echo.

rem --- 3. Network ping ---
echo [3/5] Network ping to New API host ...
ping -n 2 -w 2000 10.136.232.50 >nul 2>&1
if errorlevel 1 (
    echo   [WARN] Ping to 10.136.232.50 failed.
    echo   - Host unreachable? Check VPN / network.
) else (
    echo   - Ping OK.
)
echo.

rem --- 4. HTTP test to /v1/models ---
echo [4/5] HTTP test to %BASE_URL%/models ...
set "HTTP_CODE="
for /f "tokens=*" %%a in ('curl -s -o nul -w "%%{http_code}" --max-time 10 "%BASE_URL%/models" 2^>^&1') do set "HTTP_CODE=%%a"
echo   HTTP code: !HTTP_CODE!
if "!HTTP_CODE!"=="200" (
    echo   - New API responds OK.
) else if "!HTTP_CODE!"=="401" (
    echo   [WARN] 401 Unauthorized. Check API key in opencode.json.
) else if "!HTTP_CODE!"=="403" (
    echo   [WARN] 403 Forbidden. API key rejected.
) else if "!HTTP_CODE!"=="404" (
    echo   [WARN] 404 Not Found. Wrong base URL or /v1/models not exposed.
) else if "!HTTP_CODE!"=="000" (
    echo   [WARN] Network unreachable.
) else (
    echo   [WARN] Unexpected HTTP status.
)
echo.

rem --- 5. Auth + Model real test ---
echo [5/5] Auth + Model test (POST /v1/chat/completions) ...
set "AUTH_CODE="
for /f "tokens=*" %%a in ('curl -s -o nul -w "%%{http_code}" --max-time 15 -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %API_KEY%" -d "{\"model\":\"%MODEL%\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}],\"max_tokens\":1}" "%BASE_URL%/chat/completions" 2^>^&1') do set "AUTH_CODE=%%a"
echo   HTTP code: !AUTH_CODE!
if "!AUTH_CODE!"=="200" (
    echo   - AUTH + MODEL OK. Pipeline ready.
) else if "!AUTH_CODE!"=="401" (
    echo   [WARN] 401 Unauthorized. API key invalid for this model.
) else if "!AUTH_CODE!"=="403" (
    echo   [WARN] 403 Forbidden. Model not permitted.
) else if "!AUTH_CODE!"=="404" (
    echo   [WARN] 404 Not Found. Model name ^"%MODEL%^" not registered in New API.
) else if "!AUTH_CODE!"=="400" (
    echo   [WARN] 400 Bad Request. Model exists but request format wrong.
) else if "!AUTH_CODE!"=="000" (
    echo   [WARN] Network unreachable.
) else (
    echo   [WARN] Unexpected HTTP status.
)
echo.

echo ============================================================
echo  Diagnostics complete.
echo ============================================================
echo.
goto :EOF

:END_FAIL
echo.
echo Diagnostics FAILED. See WARN messages above.
echo.
