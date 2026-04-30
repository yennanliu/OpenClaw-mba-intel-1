# 在 MacBook Air（Intel 晶片）本地安裝 Ollama

本指南適用於搭載 **Intel x86_64** 處理器的 MacBook Air，macOS 版本建議 12（Monterey）以上。

---

## 前置需求

- macOS 12 Monterey 或更新版本
- Intel x86_64 處理器（非 Apple Silicon）
- 至少 8 GB RAM（建議 16 GB）
- 至少 10 GB 可用硬碟空間（模型檔案較大）
- 已安裝 [Homebrew](https://brew.sh/)（選用，但建議安裝）

---

## 步驟一：安裝 Ollama

### 方法 A：官方安裝程式（推薦）

1. 前往 [https://ollama.com/download](https://ollama.com/download)
2. 點擊 **Download for macOS**，下載 `.zip` 安裝檔
3. 解壓縮後，將 `Ollama.app` 拖移至 `/Applications` 資料夾
4. 開啟 `Ollama.app`，選單列（右上角）會出現 Ollama 圖示，表示服務已啟動

### 方法 B：使用 Homebrew 安裝

```bash
brew install ollama
```

---

## 步驟二：確認 Ollama 已正常執行

開啟終端機（Terminal），執行以下指令：

```bash
curl http://127.0.0.1:11434/api/tags
```

若回傳 JSON 格式的資料（即使是空的 `{"models":[]}`），代表 Ollama 正在運行。

若使用 Homebrew 安裝，需手動啟動服務：

```bash
ollama serve &
```

---

## 步驟三：下載語言模型

Ollama 需要下載模型才能運作。以下是適合 Intel Mac 的推薦模型：

| 模型名稱 | 大小 | 說明 |
|---|---|---|
| `glm4:7b` | ~4 GB | 繁體中文友善，推薦首選 |
| `llama3.2:3b` | ~2 GB | 輕量英文模型，速度快 |
| `mistral:7b` | ~4 GB | 通用英文模型 |
| `qwen2.5:7b` | ~4 GB | 中英雙語，效果佳 |

下載模型（以 `glm4:7b` 為例）：

```bash
ollama pull glm4:7b
```

等待下載完成（依網速需要數分鐘）。

---

## 步驟四：測試模型

下載完成後，直接在終端機與模型對話：

```bash
ollama run glm4:7b
```

輸入問題後按 Enter，即可獲得回應。輸入 `/bye` 或按 `Ctrl+D` 離開對話。

---

## 常用指令一覽

```bash
# 列出已下載的模型
ollama list

# 下載模型
ollama pull <模型名稱>

# 執行模型（互動對話）
ollama run <模型名稱>

# 刪除模型
ollama rm <模型名稱>

# 查看 Ollama 版本
ollama --version

# 手動啟動服務（Homebrew 安裝者使用）
ollama serve &
```

---

## 設定環境變數（選用）

若要讓其他應用程式（如 OpenClaw）自動偵測 Ollama，將以下設定加入 `~/.zshrc`：

```bash
export OLLAMA_API_KEY="ollama-local"
export OLLAMA_BASE_URL="http://127.0.0.1:11434"
```

套用設定：

```bash
source ~/.zshrc
```

---

## 常見問題排解

### Ollama 無法啟動 / 連線失敗

```bash
# 確認服務是否在運行
pgrep -x ollama

# 若沒有輸出，手動啟動
ollama serve &
```

### Intel Mac 上模型執行速度較慢

Intel Mac 無法使用 GPU 加速（Metal），模型完全由 CPU 執行。建議選擇 3B 或 7B 以下的輕量模型，並關閉其他耗資源的應用程式。

### 磁碟空間不足

模型預設儲存於 `~/.ollama/models/`，可執行以下指令確認空間使用：

```bash
du -sh ~/.ollama/models/
```

刪除不需要的模型以釋放空間：

```bash
ollama rm <模型名稱>
```

### Homebrew libvips 衝突（影響 npm 套件）

若系統安裝了 Homebrew 版的 `libvips`，在安裝其他 npm 套件時可能衝突，請先設定：

```bash
export SHARP_IGNORE_GLOBAL_LIBVIPS=1
```

---

## 下一步

Ollama 安裝完成後，可以繼續設定 OpenClaw，讓 AI 助理透過 Telegram 或瀏覽器儀表板與您互動：

```bash
# 安裝 OpenClaw
npm install -g openclaw

# 執行設定精靈
openclaw onboard --install-daemon
```

詳細步驟請參考 [`SETUP.zh-TW.md`](./SETUP.zh-TW.md)。
