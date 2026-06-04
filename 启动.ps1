# ============================================================
# 启动.ps1 - OpenCode PowerShell 启动器
# v6 精修 (2026-06-04): 等价于 run.bat, 但用 PowerShell
# 优点: 错误处理更精细, 颜色输出, 适合开发者
# ============================================================

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " OpenCode v1.15.13 - PowerShell 启动器" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$Exe = Join-Path $ScriptRoot "bin\opencode.exe"
$Cfg = Join-Path $ScriptRoot "opencode.json"

# ---- 1. 检查二进制 ----
if (-not (Test-Path $Exe)) {
    Write-Host "[FATAL] bin\opencode.exe 不存在" -ForegroundColor Red
    Write-Host "        请先运行 setup.bat" -ForegroundColor Yellow
    exit 1
}

# ---- 2. 检查配置 ----
if (-not (Test-Path $Cfg)) {
    Write-Host "[FATAL] opencode.json 不存在" -ForegroundColor Red
    Write-Host "        请从 opencode.example.json 复制" -ForegroundColor Yellow
    exit 1
}

# ---- 3. 解析配置 ----
try {
    $Config = Get-Content $Cfg -Raw -Encoding UTF8 | ConvertFrom-Json
    $Model = $Config.model
    $BaseUrl = $Config.provider.newapi.options.baseURL
    $ApiKeyHead = $Config.provider.newapi.options.apiKey.Substring(0, [Math]::Min(8, $Config.provider.newapi.options.apiKey.Length))
} catch {
    Write-Host "[FATAL] opencode.json 解析失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] 锁定配置: $Cfg" -ForegroundColor Gray
Write-Host "[INFO] 模型:     $Model" -ForegroundColor Gray
Write-Host "[INFO] baseURL:  $BaseUrl" -ForegroundColor Gray
Write-Host "[INFO] apiKey:   $ApiKeyHead..." -ForegroundColor Gray
Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# ---- 4. 设置气隙隔离环境变量 ----
$env:OPENCODE_CONFIG = $Cfg
$env:OPENCODE_DISABLE_TELEMETRY = "1"
$env:DO_NOT_TRACK = "1"
$env:NO_COLOR = "1"

Write-Host "[INFO] 隔离模式: OPENCODE_CONFIG 已锁本地" -ForegroundColor Green
Write-Host ""
Write-Host "---- 启动 OpenCode ----" -ForegroundColor Cyan
Write-Host ""

# ---- 5. 启动 (透传所有参数) ----
& $Exe @args
exit $LASTEXITCODE
