# OpenClaw × OpenAI 安裝指南

**平台：MacBook Air（Intel 晶片）**

---

## 概覽

本指南使用 **OpenAI API 金鑰**作為模型來源，讓 OpenClaw 呼叫 GPT-5.4 等雲端模型。
與本機 Ollama 方案不同，這種方式需要一把真實的 API 金鑰——因此**金鑰保護**是本文的核心重點。

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
- OpenAI 帳號與 API 金鑰（[platform.openai.com](https://platform.openai.com)）

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

```bash
# Intel Mac 加入此環境變數以避免 sharp/libvips 衝突
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install -g openclaw@latest

# 確認安裝成功
openclaw --version
```

若出現 `openclaw: command not found`：

```bash
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 步驟四：安全設定 API 金鑰

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

**模型 / 驗證方式** → 選 `OpenAI API key`

精靈會讀取 `$OPENAI_API_KEY` 環境變數，若已設定會自動帶入，確認後按 Enter。

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

瀏覽器開啟後，在控制台輸入任何訊息，確認 GPT 有正常回應。

---

## 模型選擇建議

| 模型 | 特性 | 建議用途 |
|------|------|----------|
| `openai/gpt-5.4` | 最新旗艦，推理能力強 | 複雜任務、程式開發 |
| `openai/gpt-4o` | 速度與品質平衡 | 日常對話 |
| `openai/gpt-4o-mini` | 快速、成本低 | 簡單查詢、高頻使用 |

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

## 延伸閱讀

- OpenAI API 金鑰管理：https://platform.openai.com/api-keys
- OpenAI 用量限制設定：https://platform.openai.com/usage
- OpenClaw 官方文件：https://docs.openclaw.ai
- OpenClaw 安全信任頁面：https://trust.openclaw.ai
