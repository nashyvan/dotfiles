#!/usr/bin/env bash
#
# Run this on the OLD Mac. It pushes live state to a new Mac over rsync/ssh:
#   - tmux-resurrect saved sessions       ~/.local/share/tmux/resurrect/
#   - WezTerm resurrect layout            ~/Library/Application Support/wezterm/
#   - Claude Code history + config        ~/.claude/  +  ~/.claude.json
#   - Codex history + config              ~/.codex/
#
# Config files themselves (this repo) travel via git — clone them on the new
# Mac and run os/macos/install.sh there. This script only moves the live state
# that git doesn't track.
#
# Usage:
#   ./sync-to-new-mac.sh [user@]host      # e.g. nashyvan@macbook-pro.local  or  192.168.1.42
#   ./sync-to-new-mac.sh                  # prompts for the host
#
# Prerequisite on the NEW Mac — enable Remote Login (SSH), off by default:
#   System Settings → General → Sharing → Remote Login
#   or:  sudo systemsetup -setremotelogin on
#
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; }

# 1. Destination host ----------------------------------------------------------
DEST="${1:-}"
if [[ -z "$DEST" ]]; then
  read -r -p "Destination Mac ([user@]host, e.g. nashyvan@macbook-pro.local): " DEST
fi
[[ -z "$DEST" ]] && { err "No destination given."; exit 1; }

# 2. Pre-flight reminders ------------------------------------------------------
cat <<EOF

Before continuing, on THIS (old) Mac:
  • Quit Claude Code and the Codex app  (they use live SQLite DBs — copying while
    running can corrupt them)
  • Press ⌘S in WezTerm to snapshot its current layout

EOF
read -r -p "Ready? Press Enter to continue (Ctrl-C to abort)… " _

# 3. One SSH connection reused for every transfer (single password prompt) ------
CTRL_SOCK="$(mktemp -u "${TMPDIR:-/tmp}/ssh-mux-XXXXXX")"
SSH_OPTS=(-o ControlMaster=auto -o "ControlPath=$CTRL_SOCK" -o ControlPersist=600)
cleanup() { ssh "${SSH_OPTS[@]}" -O exit "$DEST" 2>/dev/null || true; }
trap cleanup EXIT

info "Opening SSH connection to ${DEST}…"
if ! ssh "${SSH_OPTS[@]}" -o ConnectTimeout=10 "$DEST" true; then
  err "Cannot SSH to $DEST."
  echo "    On the NEW Mac: sudo systemsetup -setremotelogin on"
  echo "    (or use AirDrop — see README). Check the host with 'scutil --get LocalHostName'."
  exit 1
fi
ok "Connected to $DEST"
RSYNC_SSH="ssh -o ControlPath=$CTRL_SOCK"

# 4. Snapshot tmux sessions right now ------------------------------------------
RESURRECT_SAVE="$HOME/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"
if tmux info >/dev/null 2>&1 && [[ -x "$RESURRECT_SAVE" ]]; then
  info "Snapshotting current tmux sessions…"
  tmux run-shell "$RESURRECT_SAVE" && ok "tmux snapshot saved" || warn "tmux save failed — using last saved state"
else
  warn "No running tmux server — syncing whatever was last saved"
fi

# 5. Transfers -----------------------------------------------------------------
# run_rsync <label> <rsync args...> ; skips gracefully if the source is missing.
run_rsync() {
  local label="$1"; shift
  info "Syncing ${label}…"
  if rsync -a -e "$RSYNC_SSH" "$@"; then
    ok "${label} synced"
  else
    warn "${label} sync failed (see above) — continuing"
  fi
}

# tmux sessions
[[ -d "$HOME/.local/share/tmux/resurrect" ]] && \
  run_rsync "tmux sessions" \
    "$HOME/.local/share/tmux/resurrect/" "$DEST:~/.local/share/tmux/resurrect/"

# WezTerm layout (whole app-support dir: resurrect plugin + its state/).
# The path has a space, so the remote side is backslash-escaped for the remote shell.
[[ -d "$HOME/Library/Application Support/wezterm" ]] && \
  run_rsync "WezTerm layout" \
    "$HOME/Library/Application Support/wezterm/" "$DEST:~/Library/Application\\ Support/wezterm/"

# Claude Code history/config (auth lives in the macOS Keychain — re-login on the new Mac)
[[ -d "$HOME/.claude" ]] && \
  run_rsync "Claude Code history" \
    --exclude 'cache/' --exclude 'paste-cache/' --exclude 'shell-snapshots/' \
    --exclude 'backups/' --exclude 'telemetry/' --exclude 'plugins/' \
    "$HOME/.claude/" "$DEST:~/.claude/"
[[ -f "$HOME/.claude.json" ]] && \
  run_rsync "Claude Code config" "$HOME/.claude.json" "$DEST:~/.claude.json"

# Codex history/config (drops ~540M of caches/logs/plugins; auth.json is included)
[[ -d "$HOME/.codex" ]] && \
  run_rsync "Codex history" \
    --exclude 'plugins/' --exclude 'computer-use/' --exclude 'log/' \
    --exclude 'cache/' --exclude 'logs_2.sqlite*' --exclude 'models_cache.json' \
    --exclude '.tmp/' --exclude 'tmp/' --exclude 'ipc/' --exclude 'process_manager/' \
    --exclude '..codex-global-state.json.tmp-*' --exclude '.DS_Store' \
    "$HOME/.codex/" "$DEST:~/.codex/"

echo
ok "Done. On the NEW Mac: run os/macos/install.sh, then 'claude' + /login."
