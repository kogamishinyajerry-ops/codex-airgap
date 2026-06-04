# Troubleshooting Guide

## 决策树:诊断到修复 5 分钟

```
[问题] OpenCode 不能用
   |
   v
[Step 1] 跑 verify.bat,看哪个 step 报错
   |
   +-- [1/5] 二进制 missing    --> 跑 setup.bat
   +-- [2/5] 配置 missing      --> 从 .example.json 复制
   +-- [3/5] ping failed       --> 检查网络 / VPN
   +-- [4/5] HTTP != 200/401   --> 见下表
   +-- [5/5] HTTP != 200/401   --> 见下表
   |
   v
[Step 2] 按错误码查表
```

## 错误码速查

| HTTP 码 | 含义 | 常见原因 | 修复 |
|---------|------|----------|------|
| 200 | OK | 完美 | 无需操作 |
| 000 | 网络不可达 | 内网机器无网 / VPN 没接 / 路由错 | 检查 `ipconfig`,确认能 ping `10.136.232.50` |
| 401 | 未授权 | API Key 无效或过期 | 改 `opencode.json` 里的 `apiKey`,问 IT 要新 Key |
| 403 | 禁止 | API Key 被禁用 / 模型未授权给该 Key | 联系 New API 管理员开权限 |
| 404 | 端点未找到 | 端点路径错 / New API 没开此端点 | 核对 `opencode.json` 里的 `baseURL`,确认含 `/v1` |
| 500 | 服务器内部错 | New API 后端故障 | 联系 New API 管理员,稍后重试 |
| 502/503/504 | 网关错 | New API 代理层故障 | 同上 |

## 真机调试手法

### 1. 手动 curl 测 New API
```cmd
curl -v -X POST http://10.136.232.50/v1/chat/completions ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer <你的 Key>" ^
  -d "{\"model\":\"GLM-5.1-AWQ-4bit\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}],\"max_tokens\":1}"
```

期望: 200 + 简短 JSON 响应
如果 401: Key 无效
如果 404: 模型名错(在 New API 渠道里查实际注册的模型名)

### 2. 查看 OpenCode 启动日志
```cmd
set OPENCODE_LOG_LEVEL=debug
bin\opencode.exe
```
(具体环境变量名以 OpenCode 文档为准)

### 3. 临时切换到 mock 模型
如怀疑是 New API 端故障,可在 `opencode.json` 把 `model` 改成 `newapi/dummy` 看 OpenCode 本身是否正常报错。

## 已知坑位

### 坑 1: VC++ 缺失
**症状**: `opencode.exe` 启动后报 `VCRUNTIME140.dll not found`
**原因**: OpenCode 是 Rust 编译,需 VC++ 2015-2022 Redistributable
**修复**: 装一次即可
```cmd
# 从 Windows Update 装(在线)
# 或从内网文件服务器装 vcredist_x64.exe
```

### 坑 2: 路径含空格
**症状**: `opencode.exe` 报 "config not found",但 `opencode.json` 明明在
**原因**: `run.bat` 里 `%~dp0` 在路径含空格时可能丢引号
**修复**: 已用 `set "OPENCODE_CONFIG=%~dp0opencode.json"` 完整引号包裹,如仍报,把 `codex-airgap` 移到无空格路径(如 `D:\codex\`)

### 坑 3: PowerShell 执行策略
**症状**: `setup.bat` Step 1 解压失败,报 "running scripts is disabled"
**原因**: `Expand-Archive` 触发 PowerShell 执行策略
**修复**: `setup.bat` 已用 `powershell -NoProfile -Command`,绕过该问题

### 坑 4: 防火墙
**症状**: `ping` 通,`curl` 报 000
**原因**: Windows Defender Firewall 阻止了 `curl.exe` 出站
**修复**: 控制面板 → Windows Defender 防火墙 → 允许应用通过防火墙 → 添加 `curl.exe`

### 坑 5: 模型名大小写
**症状**: 401 显示鉴权成功但模型拒绝
**原因**: New API 内部模型名通常**严格大小写**
**修复**: 严格按 IT 提供的模型名填写,如 `GLM-5.1-AWQ-4bit` 不可写成 `glm-5.1-awq-4bit`

### 坑 6: `/v1` 后缀
**症状**: 404 Not Found
**原因**: `baseURL` 必须以 `/v1` 结尾
**反例**: `http://10.136.232.50` (会 404)
**正例**: `http://10.136.232.50/v1`

## 联系 IT 时要问的 3 件事

1. **New API 是否暴露了 `/v1/chat/completions` 端点?**
2. **GLM-5.1-AWQ-4bit 在 New API 里注册的实际模型名是?** (大小写敏感)
3. **API Key 是否有 IP 白名单?** (如有,加上内网机器 IP)
