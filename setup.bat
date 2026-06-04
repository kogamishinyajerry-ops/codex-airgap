@echo off
rem ============================================================
rem  OpenCode v1.15.13 - First-Time Setup
rem  Generated: 2026-06-04
rem ============================================================

setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "EXE=%ROOT%bin\opencode.exe"
set "ZIP=%ROOT%downloads\opencode-windows-x64.zip"
set "CFG=%ROOT%opencode.json"
set "EXPECTED_SHA256=d102e1df3ef1617c6d03211c8a5ca10798f9552887d50ca10040468b667edae8"

echo.
echo ============================================================
echo  OpenCode v1.15.13 - First-Time Setup
echo  Target: New API ^@ http://10.136.232.50/v1
echo  Model:  GLM-5.1-AWQ-4bit
echo ============================================================
echo.

rem --- Step 1: Extract binary ---
echo [Step 1/6] Extracting opencode.exe ...
if exist "%EXE%" (
    echo   - bin\opencode.exe already exists, skipping extract.
) else (
    if not exist "%ZIP%" (
        echo   [FATAL] %ZIP% not found.
        pause
        exit /b 1
    )
    if not exist "%ROOT%bin" mkdir "%ROOT%bin"
    powershell -NoProfile -Command "Expand-Archive -LiteralPath '%ZIP%' -DestinationPath '%ROOT%bin' -Force"
    if errorlevel 1 (
        echo   [FATAL] Extract failed.
        pause
        exit /b 1
    )
    echo   - Extract OK.
)
echo.

rem --- Step 2: Verify SHA256 ---
echo [Step 2/6] Verifying SHA256 ...
set "ACTUAL_SHA256="
for /f "skip=1 tokens=* delims= " %%a in ('certutil -hashfile "%EXE%" SHA256 ^| findstr /v "hash certutil"') do (
    if not defined ACTUAL_SHA256 set "ACTUAL_SHA256=%%a"
)
if /i "!ACTUAL_SHA256!"=="%EXPECTED_SHA256%" (
    echo   - SHA256 matches: !ACTUAL_SHA256!
) else (
    echo   [WARN] SHA256 mismatch.
    echo   Expected: %EXPECTED_SHA256%
    echo   Actual:   !ACTUAL_SHA256!
    echo   File may be corrupted. Setup will continue.
)
echo.

rem --- Step 3: Check config ---
echo [Step 3/6] Checking opencode.json ...
if not exist "%CFG%" (
    echo   [FATAL] opencode.json not found.
    echo   Copy opencode.example.json to opencode.json and edit it.
    pause
    exit /b 1
)
echo   - Config file present.
echo.

rem --- Step 4: Verify New API connectivity ---
echo [Step 4/6] Verifying New API ...
echo   Target: http://10.136.232.50/v1/models
set "HTTP_CODE="
for /f "tokens=*" %%a in ('curl -s -o nul -w "%%{http_code}" --max-time 10 "http://10.136.232.50/v1/models" 2^>^&1') do set "HTTP_CODE=%%a"
echo   HTTP code: !HTTP_CODE!
if "!HTTP_CODE!"=="200" (
    echo   - New API reachable.
) else if "!HTTP_CODE!"=="401" (
    echo   [WARN] 401 Unauthorized. API key may be invalid.
) else if "!HTTP_CODE!"=="403" (
    echo   [WARN] 403 Forbidden. API key rejected.
) else if "!HTTP_CODE!"=="404" (
    echo   [WARN] 404 Not Found. Wrong base URL or endpoint not exposed.
) else if "!HTTP_CODE!"=="000" (
    echo   [WARN] Network unreachable. Check VPN / network.
) else (
    echo   [WARN] Unexpected status. Verify New API is up.
)
echo.

rem --- Step 5: First-run version check ---
echo [Step 5/6] Testing opencode.exe --version ...
"%EXE%" --version
if errorlevel 1 (
    echo   [FATAL] opencode.exe failed to start.
    pause
    exit /b 1
)
echo.

rem --- Step 6: Done ---
echo [Step 6/6] Setup complete.
echo.
echo ============================================================
echo  Next: Run run.bat to launch OpenCode.
echo  Diagnostic: Run verify.bat any time.
echo ============================================================
echo.
pause

endlocal
