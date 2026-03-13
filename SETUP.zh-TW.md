# OpenClaw 安裝指南

**平台：MacBook Air（Intel 晶片）**

---

## 什麼是 OpenClaw？

OpenClaw 是一個**個人 AI 助理**，運行在你自己的裝置上，不依賴任何第三方雲端服務。你可以透過 WhatsApp、Telegram、Discord 等你已在用的通訊平台與它互動，也可以直接在瀏覽器控制台使用。

本指南採用 **Ollama 本機模型**，讓你在**完全不暴露任何 API 金鑰**的情況下運行 OpenClaw。

---

## 安全原則

在開始之前，了解本指南的安全設計：

| 原則 | 做法 |
|------|------|
| 無雲端 API 金鑰 | 使用 Ollama 本機模型，不需要 OpenAI / Anthropic 等金鑰 |
| 最小網路暴露 | Gateway 綁定在 `127.0.0.1`，不對外公開 |
| 最小權限 | 不安裝不需要的頻道與插件 |
| DM 配對保護 | 預設啟用 pairing 模式，陌生人無法直接觸發 AI |
| 無明文金鑰 | 使用環境變數管理憑證，不寫入程式碼 |

---

## 系統需求

- macOS（Intel x86_64）
- Node.js 22 LTS 或 24（建議）
- npm（隨 Node.js 附帶）
- 約 4 GB 可用磁碟空間（含模型）

---

## 步驟一：安裝 Node.js

若尚未安裝，建議使用 **nvm** 管理 Node.js 版本：

```bash
# 安裝 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 重新載入 shell（或開新終端機）
source ~/.zshrc

# 安裝並啟用 Node.js 24
nvm install 24
nvm use 24
nvm alias default 24

# 確認版本
node -v   # 應顯示 v24.x.x
npm -v
```

> **不想用 nvm？** 直接從 [nodejs.org](https://nodejs.org/en/download) 下載 macOS Intel 安裝包。

---

## 步驟二：安裝 Ollama（本機 AI 推論引擎）

Ollama 讓你在本機運行開源 AI 模型，**完全不需要 API 金鑰**。

```bash
# 方法 A：官方下載頁面（推薦）
# 前往 https://ollama.com/download，下載 macOS 版本

# 方法 B：Homebrew
brew install ollama
```

安裝完成後，下載適合 Intel Mac 的模型：

```bash
# 啟動 Ollama 服務
ollama serve &

# 下載輕量模型（推薦 Intel Mac）
ollama pull glm-4.7-flash
```

> **模型大小參考**
> - `glm-4.7-flash` ≈ 4 GB（平衡效能與速度，適合 Intel Mac）
> - `llama3.3` ≈ 42 GB（較大，需要充足記憶體）

確認 Ollama 正常運行：

```bash
curl http://127.0.0.1:11434/api/tags
# 應回傳 JSON，包含已下載模型列表
```

---

## 步驟三：安裝 OpenClaw

```bash
# Intel Mac 可能有 libvips 衝突，加入環境變數以使用預編譯版本
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install -g openclaw@latest

# 確認安裝
openclaw --version
```

若出現 `openclaw: command not found`，將 npm 全域 bin 加入 PATH：

```bash
# 查看 npm 全域路徑
npm prefix -g

# 加入 ~/.zshrc（永久生效）
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 步驟四：設定 Ollama 環境變數

Ollama 本機模式不需要真實金鑰，但 OpenClaw 需要此變數來啟用自動模型發現：

```bash
# 加入 ~/.zshrc
echo 'export OLLAMA_API_KEY="ollama-local"' >> ~/.zshrc
source ~/.zshrc
```

> `ollama-local` 只是一個啟用標記，不是真實的 API 金鑰，不會送出到任何外部服務。

---

## 步驟五：執行引導精靈

```bash
openclaw onboard --install-daemon
```

精靈會逐步引導你完成設定。**請依照以下安全建議選擇**：

### 模型提供者
選擇 **Ollama** → **Local**（僅本機，無雲端）

### Gateway 綁定位址
選擇或確認為 **127.0.0.1**（不要選 0.0.0.0，那會對外開放）

### 通訊頻道
初次設定建議**跳過**，之後有需要再加。

### DM 政策
保持預設的 **pairing（配對模式）**，陌生訊息不會觸發 AI。

### Tailscale
初次設定**關閉**。

### Daemon 安裝
選擇**安裝**，讓 OpenClaw 在背景自動執行（LaunchAgent）。

---

## 步驟六：驗證安裝

```bash
# 健康狀態檢查
openclaw doctor

# 查看 Gateway 狀態
openclaw gateway status

# 開啟瀏覽器控制台
openclaw dashboard
```

瀏覽器開啟 `http://127.0.0.1:18789/` 後即可開始對話。

---

## 使用一鍵安裝腳本

若不想手動執行上述步驟，本目錄提供了自動化腳本：

```bash
# 賦予執行權限並運行
chmod +x setup-openclaw.sh
./setup-openclaw.sh
```

腳本會自動完成環境檢查、安裝、Ollama 模型下載，並啟動引導精靈。

---

## 常用指令

```bash
openclaw dashboard        # 開啟瀏覽器控制台
openclaw gateway status   # 查看 Gateway 是否運行中
openclaw gateway stop     # 停止 Gateway
openclaw models list      # 列出可用模型
openclaw models set ollama/glm-4.7-flash  # 切換模型
openclaw doctor           # 健康與安全狀態檢查
openclaw configure        # 重新設定
```

---

## 安全注意事項

### 不要做的事

```bash
# ❌ 不要將 Gateway 綁定到 0.0.0.0（會對外公開）
openclaw gateway --bind 0.0.0.0

# ❌ 不要將真實 API 金鑰寫進程式碼或 git
echo "OPENAI_API_KEY=sk-xxx" >> ~/.openclaw/config.json

# ❌ 不要在 DM 政策開放的情況下暴露到公網
```

### 建議做的事

```bash
# ✅ 定期執行安全健檢
openclaw doctor

# ✅ 僅本機存取（預設）
# Gateway 預設綁定 127.0.0.1:18789

# ✅ 若日後需要新增雲端模型，使用環境變數而非明文
export ANTHROPIC_API_KEY="$(cat ~/.secrets/anthropic_key)"

# ✅ 定期更新
npm update -g openclaw
```

---

## 疑難排解

### `openclaw` 找不到指令

```bash
npm prefix -g                        # 查看全域路徑
export PATH="$(npm prefix -g)/bin:$PATH"
```

### `sharp` 建置錯誤

```bash
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install -g openclaw@latest
```

### Ollama 模型未被偵測

```bash
# 確認 Ollama 服務在運行
curl http://127.0.0.1:11434/api/tags

# 確認環境變數已設定
echo $OLLAMA_API_KEY   # 應顯示 ollama-local

# 重啟 Ollama
killall ollama 2>/dev/null; ollama serve &
```

### Gateway 無法啟動

```bash
openclaw doctor          # 查看詳細錯誤
openclaw gateway --port 18789 --verbose   # 前景模式除錯
```

---

## 升級與移除

```bash
# 升級 OpenClaw
npm update -g openclaw

# 完整移除
openclaw gateway stop
npm uninstall -g openclaw
rm -rf ~/.openclaw
```

---

## 延伸閱讀

- 官方文件：https://docs.openclaw.ai
- 安全威脅模型：https://trust.openclaw.ai
- Ollama 模型庫：https://ollama.com/library
- 社群 Discord：https://discord.gg/clawd
