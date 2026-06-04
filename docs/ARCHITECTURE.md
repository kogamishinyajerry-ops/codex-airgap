# Architecture

## 部署链路图

```
[Windows 内网机器 (气隙/无外网)]
   |
   |--- 拷贝整个 codex-airgap/ 目录 (USB → D:\)
   |
   v
[setup.bat]
   1. 解压 opencode-windows-x64.zip -> bin\opencode.exe
   2. 校验 SHA256 (期望: 186c5d42...ed85)
   3. 检查 opencode.json
   4. curl http://10.136.232.50/v1/models (HTTP 200/401/403/404 精准告警)
   5. opencode.exe --version (首次测试)
   6. 完成
   |
   v
[run.bat]
   - set OPENCODE_CONFIG=%~dp0opencode.json (锁本地配置)
   - 启动 bin\opencode.exe
   |
   v
[OpenCode 进程]
   - 读 opencode.json -> provider.newapi.options.baseURL = http://10.136.232.50/v1
   - 读 provider.newapi.options.apiKey = sk-...
   - 读 provider.newapi.models.GLM-5.1-AWQ-4bit
   - 用户输入 prompt -> 通过 OpenAI Chat Completions 协议发送
   |
   v
[New API @ http://10.136.232.50/v1]
   - 接收 /v1/chat/completions POST
   - 路由到 GLM-5.1-AWQ-4bit 后端
   - 流式返回结果
   |
   v
[OpenCode TUI 展示结果给用户]
```

## 文件依赖图

```
README.md  ──┐
             ├──> 文档入口
docs/      ──┘

opencode.json ──┐
                ├──> OpenCode 进程读取
OPENCODE_CONFIG ┘    (run.bat 锁定)

bin/opencode.exe ──> 单文件二进制,无外部依赖 (除 VC++ Redist)

downloads/opencode-windows-x64.zip ──> setup.bat 解压源

verify.bat ──> 独立诊断 (不依赖 run.bat / setup.bat)
```

## 离线边界

**气隙内**: U 盘 / D:\codex-airgap 目录
- ✅ 所有 .bat / .json / .md
- ✅ `bin\opencode.exe` (151 MB)
- ✅ `downloads\opencode-windows-x64.zip` (48.5 MB)

**联网需求**:
- 安装时: 装一次 VC++ Redist (从 Windows Update 或离线包)
- 运行时: **只连** `http://10.136.232.50/v1` (New API)
- 不连: GitHub / npm / OpenCode 更新服务器 / telemetry

**关键保障**:
- `run.bat` 锁定 `OPENCODE_CONFIG` 到本地,不走远程配置
- `opencode.json` 是项目级配置,优先级最高
- OpenCode 启动后只调用配置的 `baseURL`,无外发请求
