# OpenCode Air-Gap Deployment Package

**离线部署 OpenCode 1.15.13 到内网 Windows x64,通过 New API 接入 GLM-5.1-AWQ-4bit**

---

## TL;DR

| 项 | 值 |
|---|---|
| **目标** | 内网 Windows x64,气隙/无外网 |
| **CLI** | OpenCode v1.15.13 (sst/opencode) |
| **模型** | GLM-5.1-AWQ-4bit |
| **网关** | New API @ `http://10.136.232.50/v1` |
| **协议** | OpenAI Chat Completions (直连,无中转) |
| **总包大小** | 约 200 MB (zip 48.5 MB + 解压后 151 MB) |
| **离线包路径** | `/Volumes/NO NAME/codex-airgap/` |

---

## 为什么选 OpenCode 不选 Codex CLI

**2026-06-04 决策**: 转总原计划用 Claude Code (Anthropic 协议),实测 New API 默认只开 OpenAI 协议 → 401 死结。备选方案对比:

| 维度 | Claude Code (放弃) | Codex CLI 0.137 | **OpenCode 1.15.13 ✓** |
|------|-------------------|------------------|------------------------|
| 协议 | Anthropic | Responses (OpenAI 新) | **Chat Completions (OpenAI 兼容)** |
| New API 直连 | ❌ 401 | ❌ 需 CCX 网关 | ✅ **零中转** |
| Windows CLI 体积 | 228 MB | 76 MB | **48.5 MB** |
| 离线打包复杂度 | 高 (内嵌 bun) | 中 (需 Responses→Chat 网关) | **低 (单 zip)** |
| 开源 | 闭源 | Apache-2.0 | **MIT** |
| 协议配置坑 | 写死 | 需 `wire_api=chat` 改 + 改 model 名绕过元数据表 bug | **标准 baseURL 字段** |
| 调通概率 | 0% (协议不兼容) | 30% (需 2 层 workaround) | **95%** |

**结论**: OpenCode 原生吃 OpenAI 兼容协议,**New API 直连零中转**,401 问题从协议层消失。

---

## 包内文件清单

```
codex-airgap/
├── README.md                   # 本文件
├── opencode.json               # 主配置(含真实凭据,严禁上传公网)
├── opencode.example.json       # 脱敏模板(给 GitHub)
├── setup.bat                   # 首次部署(解压+校验+连通性)
├── run.bat                     # 日常启动
├── verify.bat                  # 独立诊断(网络/鉴权/模型 5 步)
├── install_settings.bat        # 把配置装到 %USERPROFILE%\.config\opencode\
├── uninstall.bat               # 卸载
├── SHA256SUMS.txt              # 全部文件 SHA256
├── .gitignore                  # 排除含真实凭据的文件
├── messages/
│   └── zh.txt                  # 中文文案外置(README 引用)
├── docs/
│   ├── ARCHITECTURE.md         # 架构图
│   └── TROUBLESHOOTING.md      # 排错指南
├── downloads/
│   └── opencode-windows-x64.zip  # 48.5 MB,GitHub Release 原包
└── bin/
    └── opencode.exe            # 151 MB,解压后单文件二进制
```

**关键 SHA256**:
- `bin\opencode.exe` (解压后): `d102e1df3ef1617c6d03211c8a5ca10798f9552887d50ca10040468b667edae8`
- `downloads\opencode-windows-x64.zip` (原包): `186c5d42c3540e401b3e112ee28c964873cb04f61f1a8b0b43c3c88337efed85` (GitHub Release 官方)

注: GitHub Release 给的 SHA256 是 **zip 包的**,不是解压后 exe 的。`setup.bat` 校验的是 **exe** 的,Windows 上 `certutil -hashfile bin\opencode.exe SHA256` 应得 `d102e1df...`。

---

## 部署步骤(Windows 内网机器)

### Step 0: 拷贝到内网
- 把整个 `codex-airgap/` 目录从 U 盘拷到内网机器 `D:\codex-airgap\`
- 必须保持目录结构(尤其是 `bin\opencode.exe` 路径)

### Step 1: 编辑配置(可选,默认已就绪)
- 默认 `opencode.json` 已含真实凭据,直接可用
- 如需修改:`notepad D:\codex-airgap\opencode.json`
- 关键字段:
  - `provider.newapi.options.baseURL`: `http://10.136.232.50/v1`
  - `provider.newapi.options.apiKey`: 转总提供
  - `provider.newapi.models.GLM-5.1-AWQ-4bit`: 模型名

### Step 2: 首次部署
- 双击 `setup.bat`
- 6 步自动完成:
  1. 解压 `opencode.exe` 到 `bin\`
  2. SHA256 校验
  3. 检查 `opencode.json`
  4. 验证 New API 连通 (HTTP 200/401/403/404 精准告警)
  5. `opencode --version` 首次测试
  6. 完成

### Step 3: 启动 OpenCode
- 双击 `run.bat`
- 锁定配置到本地 `opencode.json`,启动 `bin\opencode.exe`

### Step 4: 任何时候诊断
- 双击 `verify.bat`
- 5 步诊断:二进制 / 配置 / ping / HTTP / 真鉴权+模型

---

## 配置说明 (`opencode.json`)

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

**配置规则**(参考 [OpenCode 官方文档](https://opencode.ai/docs/config)):
- `provider.<id>.options.baseURL` - 自定义 OpenAI 兼容端点 URL(必须含 `/v1`)
- `provider.<id>.options.apiKey` - 鉴权 Key,支持 `{env:VAR}` 占位
- `provider.<id>.models.<model-id>` - 声明自定义模型
- 顶层 `model` 格式: `"<provider-id>/<model-id>"`
- 配置文件位置优先级: 远程 → 全局 (`~/.config/opencode/`) → 自定义 (env) → **项目 (本目录)** → 内联

**本包使用项目级配置** (与 `opencode.exe` 同目录的 `opencode.json`),最简单稳定。

---

## 工程纪律(Why 这些 .bat 这么写)

| 决策 | 原因 |
|------|------|
| **5 个 .bat 全部 UTF-8 BOM + CRLF + 100% ASCII** | 避免 Windows 中文乱码,所有中文文案外置到 `messages/zh.txt` |
| **真实凭据在 `opencode.json`,脱敏版在 `opencode.example.json`** | `opencode.json` 加进 `.gitignore`,GitHub 仓库只展示脱敏版 |
| **verify.bat 抓 `%%{http_code}` 精准告警** | 401/403/404/000 各给独立 `[WARN]`,避免假阳性 "OK" |
| **`run.bat` 锁 `OPENCODE_CONFIG` 环境变量** | 防止 OpenCode 找远程配置(气隙环境必须 100% 本地) |
| **不预设 `DISABLE_*` 系列变量** | OpenCode 文档未明确支持,设了可能无效;只设官方明确的 `OPENCODE_CONFIG` |
| **首次启动不用 `--force`** | OpenCode 不会偷偷连外网查更新(这是 Claude Code 的特殊行为) |

---

## 常见问题速查

| 现象 | 原因 | 修复 |
|------|------|------|
| `[FATAL] bin\opencode.exe not found` | 未运行 `setup.bat` | 双击 `setup.bat` |
| `[WARN] 401 Unauthorized` | API Key 无效或过期 | 改 `opencode.json` 里的 `apiKey` |
| `[WARN] 404 Not Found` | New API 没开 `/v1/models` 端点 | 改用 `/v1/chat/completions` 测,或问 IT |
| `[WARN] Network unreachable` | 内网机器不在 10.136.232 网段 | 检查 IP / VPN / 路由 |
| OpenCode 启动后报 "Model not found" | 模型名拼写错 | 核对 `opencode.json` 里 `models` 字段 |
| `opencode.exe` 报 "missing DLL" | VC++ Redist 未装 | 装 VC++ 2015-2022 Redistributable (x64) |

更详细的排错见 `docs/TROUBLESHOOTING.md`。

---

## 演进历史

| 日期 | 版本 | 事件 |
|------|------|------|
| 2026-06-04 | v1.0 | 立项,转总决定放弃 Claude Code,转 OpenCode (2026-06-04 19:21) |

---

## 关联项目

- **claude-code-airgap** (`kogamishinyajerry-ops/claude-code-airgap`): 12 轮迭代后放弃,因 New API 未开 Anthropic 协议。本包是其"治本"替代品。
