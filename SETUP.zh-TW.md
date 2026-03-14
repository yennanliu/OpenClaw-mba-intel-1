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

## 進階功能：網路搜尋與資料收集

OpenClaw 內建兩個網路工具，讓 Bot 能主動上網查資料：

| 工具 | 功能 |
|------|------|
| `web_search` | 用 Brave / Perplexity 等搜尋引擎查詢 |
| `web_fetch` | 抓取任意網址的內容（HTML → 純文字） |

> `web_fetch` 預設**已啟用**，不需要 API 金鑰，可直接要求 Bot 「讀取這個網址」。
> `web_search` 需要搜尋引擎的 API 金鑰（推薦 Brave，每月 1,000 次免費）。

### 啟用網路搜尋（Brave Search）

**取得 Brave Search API 金鑰：**
1. 前往 https://brave.com/search/api/ 建立帳號
2. 選擇 **Search** 方案（每月 $5 免費額度，足夠個人使用）
3. 建立 API 金鑰

**安全設定金鑰（勿明文寫入）：**

```bash
# 用編輯器開啟，避免 echo 留在 shell 歷史
nano ~/.zshrc
```

加入：

```bash
# OpenClaw — Brave Search（網路搜尋）
export BRAVE_API_KEY="BSA你的金鑰"
```

套用：

```bash
source ~/.zshrc
```

**套用到 OpenClaw：**

```bash
openclaw configure --section web
# 選 Brave，確認金鑰已讀入
```

**測試：** 在 Dashboard 或 Telegram 輸入「請搜尋今天台灣的天氣」，Bot 應回傳搜尋結果。

---

## 進階功能：呼叫外部 API

Bot 透過 `web_fetch` 直接呼叫任何 REST API（GET 請求），或透過 `exec` 工具執行 `curl` 發送 POST / 帶認證的請求。

### 範例：呼叫公開 API

直接在對話中說：

```
請呼叫 https://api.exchangerate-api.com/v4/latest/USD 並告訴我今日台幣匯率
```

Bot 會用 `web_fetch` 讀取 JSON 並解析回答。

### 範例：呼叫需要 API 金鑰的服務

先把金鑰設為環境變數（不要直接貼在對話中）：

```bash
# 在 ~/.zshrc 加入
export MY_SERVICE_API_KEY="你的金鑰"
```

然後告訴 Bot：

```
使用環境變數 $MY_SERVICE_API_KEY 作為 Bearer token，呼叫 https://api.example.com/data
```

Bot 會用 `exec` 執行 `curl`，金鑰不會出現在對話記錄中。

---

## 進階功能：寄送電子郵件

OpenClaw 透過 `exec` 工具執行系統指令寄信。推薦使用 **msmtp**（輕量 SMTP 客戶端）。

### 安裝 msmtp

```bash
brew install msmtp
```

### 設定 SMTP（以 Gmail 為例）

**建立 Gmail App Password（需開啟兩步驟驗證）：**
1. 前往 Google 帳號 → 安全性 → 應用程式密碼
2. 建立一組 App Password（16 位英文字）

**安全設定密碼（存入 macOS Keychain）：**

```bash
security add-generic-password \
  -a "your.email@gmail.com" \
  -s "msmtp-gmail" \
  -w "你的App密碼"
```

**建立 msmtp 設定檔（`~/.msmtprc`）：**

```bash
nano ~/.msmtprc
```

內容（密碼從 Keychain 動態讀取，不明文存放）：

```
defaults
  auth           on
  tls            on
  tls_trust_file /etc/ssl/cert.pem
  logfile        ~/.msmtp.log

account gmail
  host           smtp.gmail.com
  port           587
  from           your.email@gmail.com
  user           your.email@gmail.com
  passwordeval   security find-generic-password -a "your.email@gmail.com" -s "msmtp-gmail" -w

account default : gmail
```

設定檔權限收緊（避免其他使用者讀取）：

```bash
chmod 600 ~/.msmtprc
```

**測試寄信：**

```bash
echo "Subject: 測試\n\n這是 OpenClaw 寄出的測試信件" | msmtp recipient@example.com
```

**告訴 Bot 寄信：**

```
請幫我寄一封信給 friend@example.com，主旨「會議通知」，內文：明天下午三點開會
```

Bot 會呼叫 `exec` 執行 msmtp 寄出。

> **安全提醒：** 永遠不要在對話中直接說出密碼或 API 金鑰，應使用環境變數或 Keychain。

---

## 設定 Telegram 頻道

透過 Telegram 與你的 OpenClaw Bot 對話，隨時隨地都能使用。

### 步驟 1：建立 Telegram Bot

1. 打開 Telegram，搜尋並開啟 **@BotFather**（確認是官方帳號，藍色勾勾）
2. 發送 `/newbot`
3. 依提示輸入 Bot 名稱與用戶名（用戶名需以 `bot` 結尾，例如 `MyOpenClawBot`）
4. BotFather 會回傳一組 **Bot Token**（格式：`123456789:AAF...`）

> **Bot Token 等同密碼，請妥善保管，不要分享或提交到 git。**

### 步驟 2：取得你的 Telegram 用戶 ID

安全取法（不透過第三方 Bot）：

```bash
# 啟動 Gateway 並開啟 log 監聽
openclaw gateway --verbose &
openclaw logs --follow &

# 用 Telegram 向你的 Bot 發送任意訊息
# 在 log 中找 "from.id"，那就是你的 Telegram 數字 ID
```

### 步驟 3：安全設定 Bot Token

```bash
# 用編輯器加入，避免留在 shell 歷史
nano ~/.zshrc
```

加入：

```bash
# OpenClaw — Telegram Bot Token
export TELEGRAM_BOT_TOKEN="123456789:AAF你的Token"
```

套用：

```bash
source ~/.zshrc
```

### 步驟 4：設定 OpenClaw config

編輯 `~/.openclaw/openclaw.json`，加入 Telegram 頻道設定：

```json5
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "dmPolicy": "allowlist",
      "allowFrom": ["你的數字ID"],
      "groups": { "*": { "requireMention": true } }
    }
  }
}
```

> **`dmPolicy: "allowlist"` + 明確的 `allowFrom` 是最安全的設定**，只有你自己能觸發 Bot。

### 步驟 5：重啟 Gateway 並配對

```bash
openclaw gateway stop
openclaw gateway start

# 向 Bot 發送第一則訊息
# 若 dmPolicy 為 pairing，執行以下命令核准：
openclaw pairing list telegram
openclaw pairing approve telegram <CODE>
```

### BotFather 安全設定（建議）

在 @BotFather 執行：

```
/setprivacy → Enabled   （Bot 只看到被 @ 提及的群組訊息）
/setjoingroups → Disabled   （禁止 Bot 被加入不明群組）
```

---

## 設定 WhatsApp 頻道

透過 WhatsApp 與你的 OpenClaw Bot 對話。

> **建議使用備用號碼**（非個人主要號碼）連接 WhatsApp，避免日常訊息干擾 Bot。

### 步驟 1：設定存取政策

編輯 `~/.openclaw/openclaw.json`，加入 WhatsApp 設定：

```json5
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+886912345678"],
      "groupPolicy": "allowlist",
      "groupAllowFrom": ["+886912345678"]
    }
  }
}
```

> `allowFrom` 填入你**自己的手機號碼**（E.164 格式），確保只有你能觸發 Bot。

### 步驟 2：掃描 QR Code 連接 WhatsApp

```bash
openclaw channels login --channel whatsapp
```

終端機會顯示 QR Code，用 **WhatsApp 手機 App** 掃描：
- iPhone：設定 → 已連結的裝置 → 連結裝置
- Android：右上角三點選單 → 已連結的裝置 → 連結裝置

### 步驟 3：啟動 Gateway

```bash
openclaw gateway start
```

### 步驟 4：首次配對（如使用 pairing 模式）

用 WhatsApp 向已連結的號碼發送任意訊息，若收到配對碼，執行：

```bash
openclaw pairing list whatsapp
openclaw pairing approve whatsapp <CODE>
```

### 確認連線

```bash
openclaw gateway status
# 應看到 whatsapp: connected
```

---

## 安全設定總覽（更新版）

| 功能 | 金鑰 / 憑證 | 安全儲存方式 |
|------|------------|-------------|
| Ollama 本機模型 | 無需金鑰 | — |
| 網路搜尋（Brave） | `BRAVE_API_KEY` | `~/.zshrc` 環境變數 |
| Gmail 寄信 | App Password | macOS Keychain |
| Telegram Bot | `TELEGRAM_BOT_TOKEN` | `~/.zshrc` 環境變數 |
| WhatsApp | QR 連結（session 存於本機） | `~/.openclaw/credentials/` |

---

## 延伸閱讀

- 官方文件：https://docs.openclaw.ai
- 安全威脅模型：https://trust.openclaw.ai
- Ollama 模型庫：https://ollama.com/library
- Brave Search API：https://brave.com/search/api/
- 社群 Discord：https://discord.gg/clawd
