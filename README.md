# OpenCode Air-Gap Deployment Package

**离线部署 OpenCode 1.15.13 到内网 Windows x64，通过 New API 接入 GLM-5.1-AWQ-4bit**

---

## TL;DR

| 项 | 值 |
|---|---|
| **目标** | 内网 Windows x64，气隙/无外网 |
| **CLI** | OpenCode v1.15.13 (sst/opencode) |
| **模型** | GLM-5.1-AWQ-4bit |
| **网关** | New API @ `http://10.136.232.50/v1` |
| **协议** | OpenAI Chat Completions (直连，无中转) |
| **总包大小** | 约 250 MB (zip 48.5 MB + 解压后 151 MB + 依赖 50 MB) |
| **离线包路径** | `/Volumes/NO NAME/codex-airgap/` |
| **v6 精修日期** | 2026-06-04 |

---

## 为什么 v6 精修？

转总在 19:21 立项 v1.0 后，发现 3 个**生产隐患**，立即做 v6 精修：

1. **🔴 安全问题** — `verify.bat` 第 11 行硬编码了真实 API key，已 push 到公开 GitHub → **该 key 必须作废**
2. **🟡 工程纪律** — 脚本里有 95% 英文 echo，中文文案 `messages/zh.txt` 写了但**未使用** → 与 claude-code-airgap / pi-coding-agent-airgap v6 标准不一致
3. **🟡 完整性** — 缺 `install_deps.bat` / `.env.template` / `manifest.json` / `启动.ps1` / 精修说明

v6 精修解决以上 3 个问题，统一到跨项目 v6 工程纪律。

---

## 快速开始（4 步）

### Step 0：拷贝到内网
```
把整个 codex-airgap/ 目录从 U 盘拷到内网机器 D:\codex-airgap\
必须保持目录结构（尤其是 bin\opencode.exe 路径）
```

### Step 1：填凭据（必须）
```cmd
copy opencode.example.json opencode.json
notepad opencode.json
```
填入真实 `apiKey`。**这个文件已在 .gitignore 永远不会被 push。**

### Step 2：装依赖 + 首次部署
```cmd
:: 可选: 装 VC++ Redist (一次性)
install_deps.bat

:: 主流程: 解压 + 校验 + 7 步验证
setup.bat
```

### Step 3：日常启动
```cmd
run.bat                  :: 走 .bat
启动.ps1                 :: 走 PowerShell (颜色更友好)
```

### Step 4：日常诊断
```cmd
verify_airgap.bat        :: 5 步独立诊断
```

---

## 为什么选 OpenCode 不选 Codex CLI

**2026-06-04 决策**：转总原计划用 Claude Code（Anthropic 协议），实测 New API 默认只开 OpenAI 协议 → 401 死结。备选方案对比：

| 维度 | Claude Code (放弃) | Codex CLI 0.137 | **OpenCode 1.15.13 ✓** |
|------|-------------------|------------------|------------------------|
| 协议 | Anthropic | Responses (OpenAI 新) | **Chat Completions (OpenAI 兼容)** |
| New API 直连 | ❌ 401 | ❌ 需 CCX 网关 | ✅ **零中转** |
| Windows CLI 体积 | 228 MB | 76 MB | **48.5 MB** |
| 离线打包复杂度 | 高（内嵌 bun） | 中（需 Responses→Chat 网关） | **低（单 zip）** |
| 开源 | 闭源 | Apache-2.0 | **MIT** |
| 协议配置坑 | 写死 | 需 `wire_api=chat` 改 + 改 model 名绕过元数据表 bug | **标准 baseURL 字段** |
| 调通概率 | 0% (协议不兼容) | 30% (需 2 层 workaround) | **95%** |

**结论**：OpenCode 原生吃 OpenAI 兼容协议，**New API 直连零中转**，401 问题从协议层消失。

---

## 包内文件清单（v6 精修后 8 个脚本）

```
codex-airgap/
├── README.md                   # 本文件
├── opencode.json               # 主配置 (含真实凭据, .gitignore)
├── opencode.example.json       # 脱敏模板
├── .env.template               # 脱敏环境变量模板 (新增, v6)
├── manifest.json               # 机器可读部署清单 (新增, v6)
├── setup.bat                   # 首次部署 (7 步, v6)
├── run.bat                     # 日常启动 (v6: 锁配置 + 隔离兜底)
├── verify_airgap.bat           # 5 步独立诊断 (v6: 改名统一 + 去硬编码 Key)
├── verify.bat                  # 旧名 wrapper (兼容老调用)
├── install_deps.bat            # VC++ 一键安装 (新增, v6)
├── install_settings.bat        # 推配置到全局 (v6: 错误日志分开)
├── uninstall.bat               # 卸载 (v6: 二次确认)
├── 启动.ps1                    # PowerShell 启动器 (新增, v6)
├── 精修说明-2026-06-04.md      # v6 变更日志 (新增, v6)
├── SHA256SUMS.txt              # 全部文件 SHA256
├── .gitignore                  # 排除含真实凭据的文件
├── messages/
│   └── zh.txt                  # 中文文案外置 (v6: 完整覆盖 8 脚本)
├── docs/
│   ├── ARCHITECTURE.md         # 架构图
│   └── TROUBLESHOOTING.md      # 排错指南
├── dependencies/               # VC++ Redist 等离线包 (新增目录)
│   └── vc_redist.x64.exe       # 30 MB, 从 MS 官网下载
├── downloads/
│   └── opencode-windows-x64.zip  # 48.5 MB, GitHub Release 原包
└── bin/
    └── opencode.exe            # 151 MB, 解压后单文件二进制
```

**关键 SHA256**：
- `bin\opencode.exe` (解压后): `d102e1df3ef1617c6d03211c8a5ca10798f9552887d50ca10040468b667edae8`
- `downloads\opencode-windows-x64.zip` (原包): `186c5d42c3540e401b3e112ee28c964873cb04f61f1a8b0b43c3c88337efed85` (GitHub Release 官方)

> 注: GitHub Release 给的 SHA256 是 **zip 包的**，不是解压后 exe 的。`setup.bat` 校验的是 **exe** 的，Windows 上 `certutil -hashfile bin\opencode.exe SHA256` 应得 `d102e1df...`。

---

## 部署步骤详解

### Step 0: 拷贝到内网
- 把整个 `codex-airgap/` 目录从 U 盘拷到内网机器 `D:\codex-airgap\`
- 必须保持目录结构（尤其是 `bin\opencode.exe` 路径）

### Step 1: 编辑配置（必须，v6 强提示）
- 默认 `opencode.example.json` 是占位符，**不能直接用**
- 复制 `opencode.example.json` → `opencode.json`，填入真实 `apiKey`
- 关键字段：
  - `provider.newapi.options.baseURL`: `http://10.136.232.50/v1`
  - `provider.newapi.options.apiKey`: 转总提供
  - `provider.newapi.models.GLM-5.1-AWQ-4bit`: 模型名

### Step 2: 装 VC++ Redist（首次，可选）
- 双击 `install_deps.bat`
- 2 步：装 VC++ 2015-2022 Redistributable（x64）+ 验证 PowerShell
- 验证 VC++ 已装后此步可跳过

### Step 3: 首次部署
- 双击 `setup.bat`
- **7 步**自动完成（v6 精修后从 6 步扩到 7 步）：
  0. 探测 VC++ Redist（v6 新增）
  1. 解压 `opencode.exe` 到 `bin\`
  2. SHA256 校验
  3. 检查 `opencode.json`
  4. 验证 New API 连通（HTTP 200/401/403/404 精准告警）
  5. `opencode --version` 首次测试
  6. **验证外网已隔离**（v6 新增，气隙核心保障）
  7. 完成

### Step 4: 启动 OpenCode
- 双击 `run.bat`（CMD 启动器）
- 或双击 `启动.ps1`（PowerShell 启动器，错误信息更友好）
- 锁定配置到本地 `opencode.json`，启动 `bin\opencode.exe`

### Step 5: 任何时候诊断
- 双击 `verify_airgap.bat`（推荐）
- **5 步诊断**：
  1. 二进制检查
  2. 配置检查
  3. **API Key 检查（脱敏显示前 8 位，v6 安全修复）**
  4. 外网隔离验证
  5. 鉴权 + 模型真实调用测试

---

## 配置说明（`opencode.json`）

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "newapi": {
      "name": "New API (GLM-5.1-AWQ-4bit)",
      "npm": "@ai-sdk/openai-compatible",
      "models": {
        "GLM-5.1-AWQ-4bit": {}
      },
      "options": {
        "baseURL": "http://10.136.232.50/v1",
        "apiKey": "<你的 API Key>"
      }
    }
  },
  "model": "newapi/GLM-5.1-AWQ-4bit",
  "small_model": "newapi/GLM-5.1-AWQ-4bit"
}
```

**配置规则**（参考 [OpenCode 官方文档](https://opencode.ai/docs/config)）：
- `provider.<id>.options.baseURL` - 自定义 OpenAI 兼容端点 URL（必须含 `/v1`）
- `provider.<id>.options.apiKey` - 鉴权 Key，支持 `{env:VAR}` 占位
- `provider.<id>.models.<model-id>` - 声明自定义模型
- 顶层 `model` 格式：`"<provider-id>/<model-id>"`
- 配置文件位置优先级：远程 → 全局 (`~/.config/opencode/`) → 自定义 (env) → **项目（本目录）** → 内联

**本包使用项目级配置**（与 `opencode.exe` 同目录的 `opencode.json`），最简单稳定。

---

## 工程纪律（v6 精修后完整版）

| 决策 | 原因 |
|------|------|
| **8 个 .bat/.ps1 全部 UTF-8 BOM + CRLF + 100% ASCII** | 避免 Windows 中文乱码，所有中文文案外置到 `messages/zh.txt` |
| **真实凭据在 `opencode.json`，脱敏版在 `opencode.example.json`** | `opencode.json` 加进 `.gitignore`，GitHub 仓库只展示脱敏版 |
| **`verify_airgap.bat` 从 `opencode.json` 动态读 Key 并脱敏显示** | v6 安全修复，**彻底告别硬编码 Key** |
| **`verify_airgap.bat` 抓 `%%{http_code}` 精准告警** | 401/403/404/000 各给独立 `[WARN]`，避免假阳性 "OK" |
| **`run.bat` 锁 `OPENCODE_CONFIG` 环境变量** | OpenCode 官方明确支持，防止找远程配置（气隙环境必须 100% 本地） |
| **`run.bat` 兜底注入 `OPENCODE_DISABLE_TELEMETRY` / `DO_NOT_TRACK` / `NO_COLOR`** | 即使官方未明文支持也无害，提供最大气隙保障 |
| **首次启动不用 `--force`** | OpenCode 不会偷偷连外网查更新（这是 Claude Code 的特殊行为） |
| **`setup.bat` 含外网隔离验证步骤**（v6 新增） | 确保气隙环境真的"气隙"，不是"半气隙" |
| **`uninstall.bat` 必须输入 YES 二次确认** | 防误删，删除前列出所有受影响项 |
| **7 步 + 5 步诊断结构稳定** | 偏离步骤数会让用户记忆负担加重 |
| **跨项目命名统一**（`verify_airgap.bat` / `install_deps.bat` / `启动.ps1`） | 与 `claude-code-airgap` / `pi-coding-agent-airgap` 保持一致 |

---

## 内网安装部署 SOP（转总专用）

### A. 首次部署（30 分钟）

| # | 动作 | 命令 | 预期 |
|---|------|------|------|
| 1 | 拷目录 | USB → `D:\codex-airgap\` | 完整目录 |
| 2 | 填凭据 | `copy opencode.example.json opencode.json` + notepad 填 apiKey | opencode.json 含真实 key |
| 3 | 装 VC++ | 双击 `install_deps.bat` | "VC++ Redist 已安装" |
| 4 | 跑部署 | 双击 `setup.bat` | 7 步全 OK，0 个 FAIL |
| 5 | 验启动 | 双击 `run.bat` | OpenCode TUI 出现 |
| 6 | 真对话 | 输入"你好" | New API 返回中文 |
| 7 | 验退出 | 输入 `/exit` | 退出码 0 |

### B. 日常使用（1 分钟）

| # | 动作 | 命令 |
|---|------|------|
| 1 | 启动 | `run.bat` 或 `启动.ps1` |
| 2 | 干活 | 在 OpenCode TUI 里对话 |
| 3 | 退出 | `/exit` |

### C. 故障排查（5 分钟）

1. 跑 `verify_airgap.bat`，看哪一步 `[FAIL]`
2. 翻 `docs/TROUBLESHOOTING.md` 对应错误码章节
3. 仍解决不了 → 看 `messages/zh.txt` 里的提示 → 联系 IT 时带上 verify 输出

---

## 常见问题速查

| 现象 | 原因 | 修复 |
|------|------|------|
| `[FATAL] bin\opencode.exe not found` | 未运行 `setup.bat` | 双击 `setup.bat` |
| `[WARN] 401 Unauthorized` | API Key 无效或过期 | 改 `opencode.json` 里的 `apiKey` |
| `[WARN] 404 Not Found` | New API 没开 `/v1/models` 端点 | 改用 `/v1/chat/completions` 测，或问 IT |
| `[WARN] Network unreachable` | 内网机器不在 10.136.232 网段 | 检查 IP / VPN / 路由 |
| OpenCode 启动后报 "Model not found" | 模型名拼写错 | 核对 `opencode.json` 里 `models` 字段 |
| `opencode.exe` 报 "missing DLL" | VC++ Redist 未装 | 跑 `install_deps.bat` |

更详细的排错见 `docs/TROUBLESHOOTING.md`。

---

## 演进历史

| 日期 | 版本 | 事件 |
|------|------|------|
| 2026-06-04 19:21 | v1.0 | 立项，转总决定放弃 Claude Code，转 OpenCode |
| 2026-06-04 20:01 | **v6 精修** | 安全修复（去硬编码 Key）+ 工程纪律对齐 + 补齐依赖/PS1/模板/清单 |

完整 v6 变更日志见 `精修说明-2026-06-04.md`。

---

## 关联项目

- **claude-code-airgap** (`kogamishinyajerry-ops/claude-code-airgap`)：12 轮迭代后放弃，因 New API 未开 Anthropic 协议。本包是其"治本"替代品。
- **pi-coding-agent-airgap** (`kogamishinyajerry-ops/pi-coding-agent-airgap`)：Node.js 路线，备选。
