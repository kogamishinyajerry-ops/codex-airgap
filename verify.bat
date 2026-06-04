@echo off
rem ============================================================
rem  OpenCode 验证脚本 - 兼容旧名 wrapper
rem  v6 精修 (2026-06-04): 已重命名为 verify_airgap.bat 统一规范
rem  此文件保留为薄包装, 老 README/快捷方式仍能调用
rem ============================================================

chcp 65001 >nul
cd /d "%~dp0"

echo.
echo [INFO] verify.bat 已重命名为 verify_airgap.bat
echo        自动跳转到新脚本...
echo.

if exist "%~dp0verify_airgap.bat" (
    call "%~dp0verify_airgap.bat" %*
) else (
    echo [FATAL] verify_airgap.bat 不存在
    pause
    exit /b 1
)
