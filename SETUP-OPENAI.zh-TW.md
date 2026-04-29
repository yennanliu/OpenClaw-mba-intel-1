# OpenClaw × OpenAI 安裝指南

**平台：MacBook Air（Intel 晶片）**

---

## 概覽

本指南使用 **OpenAI** 作為模型來源，支援兩種驗證方式：

| 方式 | 需求 | 適合對象 |
|------|------|----------|
| **API 金鑰**（傳統） | OpenAI 帳號 + 付費 API 餘額 | 開發者、需精細用量控制 |
| **ChatGPT 訂閱登入**（推薦） | ChatGPT Plus 訂閱（$20/月） | 一般使用者，免手動管理金鑰 |

與本機 Ollama 方案不同，這種方式需要 OpenAI 帳號——因此**金鑰保護**是本文的核心重點。

---

## 安全原則

| 原則 | 做法 |
|------|------|
| 金鑰不落地 | API 金鑰存於環境變數，不寫入任何程式碼或 git |
| 最小網路暴露 | Gateway 綁定 `127.0.0.1`，不對外公開 |
| 最小權限 | OpenAI 金鑰限制只有必要的 API 存取範圍 |
| DM 配對保護 | 保持 pairing 模式，陌生人無法觸發 AI |
| 無明文儲存 | 金鑰僅透過環境變數注入，不存入 config 檔的明文欄位 |

---

## 系統需求

- macOS（Intel x86_64）
- Node.js 22 LTS 或 24（建議）
- npm
- OpenAI 帳號與 API 金鑰（[platform.openai.com](https://platform.openai.com)）**或** ChatGPT Plus 訂閱

架構確認：
```bash
uname -m   # 應顯示 x86_64
```

---

## 步驟一：取得 OpenAI API 金鑰

1. 前往 [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. 點擊 **Create new secret key**
3. 為金鑰命名（例如 `openclaw-local`），方便日後識別與撤銷
4. 複製金鑰（`sk-...`）——**只會顯示一次，請妥善保存**

### 建議的金鑰設定

建立金鑰時可限制存取範圍（Permissions），最小化風險：

| 設定項目 | 建議值 |
|----------|--------|
| Models | 僅允許 `gpt-5.4` / `gpt-4o` 等你實際使用的模型 |
| Usage limits | 設定每月消費上限（Billing → Usage limits） |
| Project | 建立獨立 Project 隔離，不用預設 Default project |

---

## 步驟二：安裝 Node.js

```bash
# 使用 nvm（推薦）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.zshrc

nvm install 24
nvm use 24
nvm alias default 24

node -v   # 應顯示 v24.x.x
```

---

## 步驟三：安裝 OpenClaw

### 方法 A：官方安裝腳本（推薦，v2026.2.26+）

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

### 方法 B：npm 全域安裝（Intel Mac 備用）

```bash
# Intel Mac 加入此環境變數以避免 sharp/libvips 衝突
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install -g openclaw@latest
```

確認安裝成功：

```bash
openclaw --version
```

若出現 `openclaw: command not found`：

```bash
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 步驟四：設定 OpenAI 驗證

### 方式 A：ChatGPT 訂閱登入（推薦，免 API 金鑰）

若你已有 **ChatGPT Plus** 訂閱，可直接用帳號驗證，無需手動管理金鑰：

```bash
openclaw onboard --install-daemon
# 精靈中選擇：OpenAI → Auth Login（而非 API key）
```

登入後可選用 Codex 模型：

```bash
openclaw models set openai-codex/gpt-5.3-codex
```

用量查看：https://chatgpt.com/codex/settings/usage

---

### 方式 B：API 金鑰（進階）

**永遠不要**把金鑰直接貼進 config 檔或 terminal 歷史記錄。
使用以下方式安全注入：

### 方法 A：寫入 `~/.zshrc`（推薦個人機器使用）

```bash
# 用文字編輯器開啟，不要用 echo 避免留在 shell 歷史
nano ~/.zshrc
```

在檔案末尾加入：

```bash
# OpenClaw — OpenAI API 金鑰（勿提交至 git）
export OPENAI_API_KEY="sk-你的金鑰貼在這裡"
```

存檔後套用：

```bash
source ~/.zshrc
```

確認金鑰已載入（只顯示前幾字）：

```bash
echo "${OPENAI_API_KEY:0:8}..."   # 應顯示 sk-xxxxx...
```

### 方法 B：使用 macOS Keychain（最安全）

```bash
# 將金鑰存入 Keychain
security add-generic-password \
  -a "$USER" \
  -s "openclaw-openai" \
  -w "sk-你的金鑰"

# 在 ~/.zshrc 中動態讀取（不明文儲存）
echo 'export OPENAI_API_KEY="$(security find-generic-password -a "$USER" -s "openclaw-openai" -w 2>/dev/null)"' >> ~/.zshrc

source ~/.zshrc
```

> Keychain 方式金鑰加密儲存在系統，即使 `~/.zshrc` 被讀取也不會洩漏金鑰值。

---

## 步驟五：執行引導精靈

```bash
openclaw onboard --install-daemon
```

### 精靈選項對照

**模型 / 驗證方式** → 依你的方案選擇：
- ChatGPT Plus 訂閱 → 選 `OpenAI Auth Login`
- API 金鑰 → 選 `OpenAI API key`（精靈會讀取 `$OPENAI_API_KEY` 環境變數，若已設定會自動帶入）

---

**Gateway 綁定位址** → 確認為 `127.0.0.1`

```
Gateway bind address: 127.0.0.1   ← 保持此值，勿改為 0.0.0.0
Gateway port: 18789
```

---

**Gateway 驗證模式** → 保持 `Token`（自動產生），勿停用驗證

---

**通訊頻道** → 初次設定建議跳過

---

**DM 政策** → 保持 `pairing`（配對模式）

---

**Tailscale** → 初次設定關閉

---

**Daemon 安裝** → 選擇安裝（macOS LaunchAgent）

---

## 步驟六：確認模型設定

精靈完成後，確認 OpenAI 模型已設為預設：

```bash
openclaw models list
# 應看到 openai/gpt-5.4 或類似條目
```

若需手動切換模型：

```bash
openclaw models set openai/gpt-5.4
```

---

## 步驟七：驗證安裝

```bash
# 安全與健康狀態檢查
openclaw doctor

# 查看 Gateway 運行狀態
openclaw gateway status

# 開啟瀏覽器控制台
openclaw dashboard
```

Gateway 啟動後，也可直接在瀏覽器開啟：`http://127.0.0.1:18789/`

在控制台輸入任何訊息，確認 GPT 有正常回應。

---

## 模型選擇建議

| 模型 | 特性 | 需求 | 建議用途 |
|------|------|------|----------|
| `openai-codex/gpt-5.3-codex` | 程式推理旗艦 | ChatGPT Plus 訂閱 | 複雜程式開發 |
| `openai/gpt-5.4` | 最新旗艦，推理能力強 | API 金鑰 | 複雜任務 |
| `openai/gpt-4o` | 速度與品質平衡 | API 金鑰 | 日常對話 |
| `openai/gpt-4o-mini` | 快速、成本低 | API 金鑰 | 簡單查詢、高頻使用 |

切換模型：

```bash
openclaw models set openai/gpt-4o-mini
```

---

## 常用指令

```bash
openclaw dashboard              # 開啟瀏覽器控制台
openclaw gateway status         # Gateway 狀態
openclaw models list            # 列出可用模型
openclaw models set openai/gpt-5.4  # 切換模型
openclaw doctor                 # 安全健檢
openclaw configure              # 重新設定
```

---

## 安全注意事項

### 不要做的事

```bash
# ❌ 不要在 terminal 直接貼入金鑰（會留在歷史紀錄）
export OPENAI_API_KEY=sk-abc123...

# ❌ 不要把金鑰寫進 openclaw.json
{ "env": { "OPENAI_API_KEY": "sk-abc123..." } }

# ❌ 不要把含金鑰的檔案加入 git
git add ~/.openclaw/openclaw.json

# ❌ 不要將 Gateway 對外開放
openclaw gateway --bind 0.0.0.0
```

### 建議做的事

```bash
# ✅ 定期執行安全健檢
openclaw doctor

# ✅ 在 OpenAI 後台設定用量上限
# platform.openai.com → Billing → Usage limits

# ✅ 定期更新
npm update -g openclaw

# ✅ 若金鑰疑似外洩，立即撤銷
# platform.openai.com/api-keys → Revoke
```

---

## 疑難排解

### 精靈未讀到 API 金鑰

```bash
# 確認環境變數已設定
echo $OPENAI_API_KEY

# 若為空，重新載入 shell 設定
source ~/.zshrc
```

### 收到 `401 Unauthorized`

- 確認金鑰未過期或被撤銷
- 前往 [platform.openai.com/api-keys](https://platform.openai.com/api-keys) 確認狀態

### 收到 `429 Rate limit`

- 確認帳戶有足夠餘額
- 在 OpenAI 後台的 Billing 頁面查看用量
- 考慮切換到 `gpt-4o-mini` 降低消耗

### `openclaw` 找不到指令

```bash
export PATH="$(npm prefix -g)/bin:$PATH"
```

### `sharp` 建置錯誤

```bash
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install -g openclaw@latest
```

---

## 金鑰洩漏應對步驟

若懷疑 API 金鑰外洩：

1. **立即撤銷**：[platform.openai.com/api-keys](https://platform.openai.com/api-keys) → Revoke
2. **查看用量**：Billing → Usage，確認是否有異常消費
3. **建立新金鑰**：重複步驟一，產生新金鑰
4. **更新環境變數**：修改 `~/.zshrc` 或 Keychain 中的金鑰值
5. **重啟 Gateway**：`openclaw gateway stop && openclaw gateway start`

---

## 升級與移除

```bash
# 升級 OpenClaw
npm update -g openclaw

# 完整移除
openclaw gateway stop
npm uninstall -g openclaw
rm -rf ~/.openclaw

# 同時記得到 OpenAI 後台撤銷金鑰
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

**安全設定金鑰（存入 macOS Keychain，最安全）：**

```bash
# 將 Brave 金鑰存入 Keychain
security add-generic-password \
  -a "$USER" \
  -s "openclaw-brave" \
  -w "BSA你的金鑰"

# ~/.zshrc 動態讀取，不明文儲存
echo 'export BRAVE_API_KEY="$(security find-generic-password -a "$USER" -s "openclaw-brave" -w 2>/dev/null)"' >> ~/.zshrc

source ~/.zshrc
```

**套用到 OpenClaw：**

```bash
openclaw configure --section web
# 選 Brave，確認金鑰已讀入
```

**測試：** 在 Dashboard 輸入「請搜尋今天台灣科技新聞」，Bot 應回傳即時搜尋結果。

### 搜尋提供者比較

| 提供者 | 金鑰環境變數 | 免費額度 | 特色 |
|--------|------------|---------|------|
| Brave | `BRAVE_API_KEY` | 1,000 次/月 | 結構化結果，隱私導向 |
| Perplexity | `PERPLEXITY_API_KEY` | 付費 | AI 合成答案 + 引用 |
| Gemini | `GEMINI_API_KEY` | 有免費額度 | Google Search 接地 |

---

## 進階功能：呼叫外部 API

Bot 透過 `web_fetch` 直接呼叫 REST API（GET），或透過 `exec` 工具執行 `curl` 發送帶認證的請求。

### 範例：呼叫公開 API

直接在對話中說：

```
請呼叫 https://api.exchangerate-api.com/v4/latest/USD 並告訴我今日台幣匯率
```

### 範例：呼叫需要 API 金鑰的服務

先把金鑰安全存入 Keychain：

```bash
security add-generic-password \
  -a "$USER" \
  -s "my-service-api" \
  -w "你的服務金鑰"

echo 'export MY_SERVICE_API_KEY="$(security find-generic-password -a "$USER" -s "my-service-api" -w 2>/dev/null)"' >> ~/.zshrc
source ~/.zshrc
```

然後告訴 Bot：

```
使用環境變數 $MY_SERVICE_API_KEY 作為 Bearer token，呼叫 https://api.example.com/data
```

> **金鑰安全層級**：OpenAI 金鑰（高敏感）→ Keychain；搜尋 API 金鑰（中敏感）→ `~/.zshrc` 環境變數亦可。
> 統一使用 Keychain 是最佳實踐。

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

**密碼存入 macOS Keychain（絕不明文）：**

```bash
security add-generic-password \
  -a "your.email@gmail.com" \
  -s "msmtp-gmail" \
  -w "你的16位App密碼"
```

**建立 msmtp 設定檔（`~/.msmtprc`）：**

```bash
nano ~/.msmtprc
```

內容（密碼從 Keychain 動態讀取）：

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

收緊檔案權限：

```bash
chmod 600 ~/.msmtprc
```

**測試寄信：**

```bash
printf "Subject: 測試\n\n這是 OpenClaw 寄出的測試信件" | msmtp recipient@example.com
```

**告訴 Bot 寄信：**

```
請幫我寄一封信給 friend@example.com，主旨「會議通知」，內文：明天下午三點開會
```

---

## 設定 Telegram 頻道

透過 Telegram 與你的 OpenClaw Bot 對話，隨時隨地都能使用。

### 步驟 1：建立 Telegram Bot

1. 打開 Telegram，搜尋並開啟 **@BotFather**（確認是官方帳號，藍色勾勾）
2. 發送 `/newbot`
3. 依提示輸入 Bot 名稱與用戶名（用戶名需以 `bot` 結尾）
4. BotFather 會回傳一組 **Bot Token**（格式：`123456789:AAF...`）

> **Bot Token 等同密碼，請妥善保管，不要分享或提交到 git。**

### 步驟 2：取得你的 Telegram 數字 ID

```bash
# 先啟動 Gateway，開 log 監聽
openclaw gateway --verbose &
openclaw logs --follow &
# 用 Telegram 向 Bot 發送任意訊息，在 log 中找 "from.id"
```

### 步驟 3：安全設定 Bot Token

最安全方式 — 存入 Keychain：

```bash
security add-generic-password \
  -a "$USER" \
  -s "openclaw-telegram" \
  -w "123456789:AAF你的Token"

echo 'export TELEGRAM_BOT_TOKEN="$(security find-generic-password -a "$USER" -s "openclaw-telegram" -w 2>/dev/null)"' >> ~/.zshrc
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

> `dmPolicy: "allowlist"` + 明確 `allowFrom` = 只有你能觸發 Bot，最安全。

### 步驟 5：重啟 Gateway 並配對

```bash
openclaw gateway stop
openclaw gateway start

# 向 Bot 發送第一則訊息，若需配對：
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

> `allowFrom` 填入你自己的手機號碼（E.164 格式），確保只有你能觸發 Bot。

### 步驟 2：掃描 QR Code 連接 WhatsApp

```bash
openclaw channels login --channel whatsapp
```

終端機顯示 QR Code 後，用 **WhatsApp 手機 App** 掃描：
- iPhone：設定 → 已連結的裝置 → 連結裝置
- Android：右上角三點選單 → 已連結的裝置 → 連結裝置

### 步驟 3：啟動 Gateway

```bash
openclaw gateway start
```

### 步驟 4：首次配對（如使用 pairing 模式）

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
| OpenAI 模型 | `OPENAI_API_KEY` | macOS Keychain（建議） |
| 網路搜尋（Brave） | `BRAVE_API_KEY` | macOS Keychain |
| 外部 API 呼叫 | 各服務金鑰 | macOS Keychain |
| Gmail 寄信 | App Password | macOS Keychain |
| Telegram Bot | `TELEGRAM_BOT_TOKEN` | macOS Keychain |
| WhatsApp | QR 連結 session | `~/.openclaw/credentials/` |

---

## 延伸閱讀

- OpenAI API 金鑰管理：https://platform.openai.com/api-keys
- OpenAI 用量限制設定：https://platform.openai.com/usage
- Brave Search API：https://brave.com/search/api/
- OpenClaw 官方文件：https://docs.openclaw.ai
- OpenClaw 安全信任頁面：https://trust.openclaw.ai
