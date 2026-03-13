#!/usr/bin/env bash
# ============================================================
# OpenClaw 安全安裝腳本
# 平台：macOS (Intel)
# 原則：最小權限、無金鑰外洩、本機推論
# ============================================================
set -euo pipefail

# ── 顏色輸出 ────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

info()  { echo -e "${BLUE}[資訊]${RESET} $*"; }
ok()    { echo -e "${GREEN}[完成]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[警告]${RESET} $*"; }
die()   { echo -e "${RED}[錯誤]${RESET} $*" >&2; exit 1; }

echo -e "${BOLD}"
cat <<'BANNER'
   ___                  _____ _
  / _ \ _ __   ___ _ __|  ___| | __ ___      __
 | | | | '_ \ / _ \ '_ \ |_  | |/ _` \ \ /\ / /
 | |_| | |_) |  __/ | | |  _| | | (_| |\ V  V /
  \___/| .__/ \___|_| |_|_|   |_|\__,_| \_/\_/
       |_|
  MacBook Air Intel 安全安裝腳本
BANNER
echo -e "${RESET}"

# ── 前置檢查 ─────────────────────────────────────────────────
check_arch() {
  local arch
  arch=$(uname -m)
  if [[ "$arch" != "x86_64" ]]; then
    warn "偵測到架構：$arch（本腳本針對 Intel x86_64 撰寫，請確認相容性）"
  else
    ok "架構確認：Intel x86_64"
  fi
}

check_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    die "本腳本僅支援 macOS"
  fi
  ok "作業系統：macOS $(sw_vers -productVersion)"
}

check_node() {
  info "檢查 Node.js 版本..."
  if ! command -v node &>/dev/null; then
    die "未找到 Node.js。請先安裝 Node.js 22 LTS 或 24：\n  https://nodejs.org/en/download\n  或使用 nvm：curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
  fi

  local node_major
  node_major=$(node -e "process.stdout.write(String(process.versions.node.split('.')[0]))")
  if (( node_major < 22 )); then
    die "需要 Node.js 22 以上，目前版本：$(node -v)\n請執行：nvm install 24 && nvm use 24"
  fi
  ok "Node.js $(node -v)"
}

check_npm() {
  if ! command -v npm &>/dev/null; then
    die "未找到 npm，請確認 Node.js 安裝完整"
  fi
  ok "npm $(npm -v)"
}

check_ollama() {
  info "檢查 Ollama（本機 AI 推論引擎）..."
  if ! command -v ollama &>/dev/null; then
    warn "未找到 Ollama。建議安裝以使用本機模型（無需 API 金鑰）："
    warn "  https://ollama.com/download"
    warn "  或：brew install ollama"
    OLLAMA_MISSING=true
  else
    ok "Ollama $(ollama --version 2>/dev/null | head -1)"
    OLLAMA_MISSING=false
  fi
}

# ── 安裝 OpenClaw ────────────────────────────────────────────
install_openclaw() {
  info "安裝 OpenClaw（全域 npm 套件）..."

  # Intel Mac 常見問題：避免 sharp 與系統 libvips 衝突
  if brew list libvips &>/dev/null 2>&1; then
    warn "偵測到 Homebrew libvips，使用預編譯 sharp 以避免衝突..."
    SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install -g openclaw@latest
  else
    npm install -g openclaw@latest
  fi

  # 確認 PATH 可找到 openclaw
  if ! command -v openclaw &>/dev/null; then
    local npm_bin
    npm_bin="$(npm prefix -g)/bin"
    warn "openclaw 指令不在 PATH 中，嘗試加入：$npm_bin"
    export PATH="$npm_bin:$PATH"

    # 寫入 shell 設定檔（永久生效）
    local shell_rc="$HOME/.zshrc"
    if ! grep -q "npm prefix -g" "$shell_rc" 2>/dev/null; then
      echo '' >> "$shell_rc"
      echo '# OpenClaw — npm global bin' >> "$shell_rc"
      echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> "$shell_rc"
      ok "已將 npm bin 路徑寫入 $shell_rc（重新開終端機後永久生效）"
    fi
  fi

  ok "OpenClaw $(openclaw --version 2>/dev/null | head -1) 安裝完成"
}

# ── 設定 Ollama 本機模型 ─────────────────────────────────────
setup_ollama_model() {
  if [[ "${OLLAMA_MISSING:-true}" == "true" ]]; then
    warn "跳過 Ollama 模型設定（未安裝 Ollama）"
    return
  fi

  info "確認 Ollama 服務已啟動..."
  if ! curl -sf http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    info "啟動 Ollama 背景服務..."
    ollama serve &>/dev/null &
    sleep 3
  fi

  # 檢查是否已有可用模型
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' || true)

  if [[ -z "$models" ]]; then
    info "下載預設本機模型（glm-4.7-flash，適合 Intel Mac）..."
    ollama pull glm-4.7-flash
    ok "模型 glm-4.7-flash 下載完成"
  else
    ok "已有本機模型：$(echo "$models" | tr '\n' ' ')"
  fi
}

# ── 安全配置 Ollama 環境變數 ─────────────────────────────────
configure_ollama_env() {
  if [[ "${OLLAMA_MISSING:-true}" == "true" ]]; then
    return
  fi

  local shell_rc="$HOME/.zshrc"

  # Ollama 本機使用不需要真實金鑰，設定虛擬值即可啟用自動發現
  if ! grep -q "OLLAMA_API_KEY" "$shell_rc" 2>/dev/null; then
    echo '' >> "$shell_rc"
    echo '# OpenClaw — Ollama 本機模型（無需真實 API 金鑰）' >> "$shell_rc"
    echo 'export OLLAMA_API_KEY="ollama-local"' >> "$shell_rc"
    ok "已寫入 OLLAMA_API_KEY=ollama-local 至 $shell_rc"
  fi

  export OLLAMA_API_KEY="ollama-local"
}

# ── 執行引導精靈 ─────────────────────────────────────────────
run_onboard() {
  echo ""
  echo -e "${BOLD}══════════════════════════════════════════${RESET}"
  echo -e "${BOLD}  即將執行 OpenClaw 引導精靈${RESET}"
  echo -e "${BOLD}══════════════════════════════════════════${RESET}"
  echo ""
  echo "  安全建議（請在精靈中選擇）："
  echo "  • 模型提供者  → 選 Ollama（本機，無需 API 金鑰）"
  echo "  • Gateway 綁定 → 127.0.0.1（僅本機，勿選 0.0.0.0）"
  echo "  • 通訊頻道    → 暫時跳過（之後再設定）"
  echo "  • DM 政策     → 維持 pairing（配對模式，最安全）"
  echo "  • Tailscale   → 暫時關閉"
  echo ""
  read -r -p "按下 Enter 繼續，或 Ctrl+C 取消..."

  openclaw onboard --install-daemon
}

# ── 安全驗證 ────────────────────────────────────────────────
post_check() {
  echo ""
  info "執行安全健檢..."
  openclaw doctor || true
  echo ""
  ok "安裝完成！常用指令："
  echo ""
  echo "  openclaw dashboard      # 開啟瀏覽器控制台"
  echo "  openclaw gateway status # 查看 Gateway 狀態"
  echo "  openclaw models list    # 列出可用模型"
  echo "  openclaw doctor         # 健康狀態檢查"
  echo ""
}

# ── 主流程 ───────────────────────────────────────────────────
main() {
  check_macos
  check_arch
  check_node
  check_npm
  check_ollama
  install_openclaw
  setup_ollama_model
  configure_ollama_env
  run_onboard
  post_check
}

main "$@"
