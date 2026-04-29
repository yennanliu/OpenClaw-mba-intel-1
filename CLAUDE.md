# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A setup guide and automated installation script for **OpenClaw** on MacBook Air (Intel x86_64). OpenClaw is a personal AI assistant that runs locally via Ollama, accessible through messaging platforms (Telegram, WhatsApp, Discord) or a browser dashboard. No cloud API keys are required.

## Key Files

- `setup-openclaw.sh` — The main automated installer. Checks prerequisites, installs OpenClaw via npm, pulls an Ollama model, and runs the onboarding wizard.
- `SETUP.zh-TW.md` — Manual step-by-step setup guide (Traditional Chinese, Ollama/local-model variant).
- `SETUP-OPENAI.zh-TW.md` — Manual setup guide using OpenAI API instead of Ollama.
- `tg_integration.txt` — Reference URLs for Telegram integration documentation.

## Running the Installer

```bash
# Make executable and run (macOS Intel only)
chmod +x setup-openclaw.sh
./setup-openclaw.sh
```

Prerequisites checked by the script: macOS, Intel x86_64, Node.js ≥ 22, npm, Ollama (optional but recommended).

## OpenClaw CLI Commands (post-install)

```bash
openclaw onboard --install-daemon   # Initial setup wizard
openclaw dashboard                  # Open browser control panel
openclaw gateway status             # Check gateway status
openclaw models list                # List available models
openclaw doctor                     # Health check
```

## Ollama Setup

```bash
ollama serve &                      # Start local inference engine
ollama pull glm-4.7-flash           # Recommended model for Intel Mac (~4 GB)
curl http://127.0.0.1:11434/api/tags  # Verify Ollama is running
```

## Security Principles

- Gateway binds to `127.0.0.1` only — never `0.0.0.0`
- Use `OLLAMA_API_KEY="ollama-local"` (placeholder, not a real key) to enable Ollama auto-discovery
- DM pairing mode enabled by default to block untrusted senders
- Intel Mac note: if Homebrew `libvips` is installed, set `SHARP_IGNORE_GLOBAL_LIBVIPS=1` before `npm install -g openclaw`

## Environment Variable

```bash
export OLLAMA_API_KEY="ollama-local"   # Required for Ollama provider; add to ~/.zshrc
```
