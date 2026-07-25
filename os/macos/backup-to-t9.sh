#!/usr/bin/env bash
#
# Back up key home-directory folders to the Samsung T9 SSD (exFAT), skipping
# regenerable dependency/build dirs under ~/Developer but KEEPING .git, .env,
# .env.local and every other source/dotfile.
#
# Each folder is synced independently into its own subfolder under the
# destination root, e.g. ~/Developer → MacBook/Developer, ~/.ssh → MacBook/.ssh.
# rsync's --delete only ever removes files *inside* the specific destination
# subfolder it's writing to — never siblings — so a mirror of ~/.ssh can never
# touch MacBook/Developer or anything else already on the drive. See "Safety"
# below for the extra guards on top of that.
#
# Folders backed up (name == both the ~/ source dir and the T9 subfolder):
#   Developer   deps/build/cache dirs skipped; .git, .env*, sources kept
#   .ssh        keys/config/known_hosts; live agent socket skipped
#   .claude     Claude Code history/config; caches/telemetry/plugins skipped
#   .codex      Codex history/config; caches/logs/plugins skipped
#   .config     dotfiles repo + gitignored local credentials (gcloud, gh, etc.);
#               regenerable gcloud/virtenv and zsh/tmux plugin clones skipped
#   .anydesk    AnyDesk alias/address book/config; caches/thumbnails skipped
#   .borgmatic  borg bootstrap manifest (disaster-recovery metadata)
#   .pgadmin    pgAdmin4 saved server connections (pgadmin4.db); logs/sessions skipped
#   Downloads, Movies   copied as-is (minus .DS_Store)
#   Music, Pictures   copied as-is; Photos/Music Library bundles skipped (app-managed, huge)
#
# Default destination root: /Volumes/T9/MacBook
#
# Why the flags aren't `rsync -a`:
#   The T9 is exFAT, which has no concept of Unix permissions, ownership, or
#   symlinks, and stores mtimes at coarse resolution. So we drop -p/-o/-g (perms/
#   owner/group would error on every file), skip symlinks instead of failing to
#   recreate them, and widen the mtime compare window so re-runs stay incremental
#   instead of re-copying everything. (This also means ~/.ssh key permissions
#   are NOT preserved on the T9 — re-`chmod 600` after restoring from backup.)
#
# Safety:
#   - Every destination is required to resolve (via realpath) to somewhere
#     inside the destination root, so a symlink escape can't send --delete
#     outside the intended subfolder.
#   - Refuses to run if the destination root is empty, "/", or $HOME.
#   - Refuses to sync a folder if its source resolves to the same path as its
#     destination (would make --delete erase the source).
#   - With --delete, skips (rather than mirrors) any folder whose source
#     directory is empty — an empty source is far more likely to mean
#     "not mounted / misconfigured" than "I deleted everything on purpose",
#     and mirroring it would wipe that folder's entire T9 copy.
#   - The T9 volume must already be mounted at the destination root; the
#     script never creates or writes into a placeholder /Volumes/T9 folder
#     left behind from an unmounted drive.
#
# Usage:
#   ./backup-to-t9.sh                          # back up every folder above
#   ./backup-to-t9.sh /Volumes/T9/MacBook       # custom destination root
#   ./backup-to-t9.sh --only=Developer,.ssh     # only these folders (comma-sep)
#   ./backup-to-t9.sh --delete                  # mirror: also remove files on
#                                                #   the T9 copy that are gone
#                                                #   locally (still scoped, and
#                                                #   still guarded, per folder)
#   ./backup-to-t9.sh --dry-run                 # show what would change, copy nothing
#
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; }

# 1. Args ------------------------------------------------------------------
DEST_ROOT="/Volumes/T9/MacBook"
DELETE=()
DRYRUN=()
MIRRORING=""
ONLY=""
for arg in "$@"; do
  case "$arg" in
    --delete)    DELETE=(--delete); MIRRORING="  (--delete: mirroring)" ;;
    --dry-run)   DRYRUN=(--dry-run) ;;
    --only=*)    ONLY="${arg#--only=}" ;;
    -*)          err "Unknown option: $arg"; exit 1 ;;
    *)           DEST_ROOT="$arg" ;;
  esac
done

ALL_FOLDERS=(Developer .ssh .claude .codex .config .anydesk .borgmatic .pgadmin Downloads Movies Music Pictures)
if [[ -n "$ONLY" ]]; then
  IFS=',' read -r -a FOLDERS <<< "$ONLY"
else
  FOLDERS=("${ALL_FOLDERS[@]}")
fi

# 2. Pre-flight checks -------------------------------------------------------
[[ -n "$DEST_ROOT" && "$DEST_ROOT" != "/" && "$DEST_ROOT" != "$HOME" ]] || {
  err "Refusing to use destination root '$DEST_ROOT' — looks unsafe."
  exit 1
}

# The mount point may exist even when unmounted; require the volume root to be
# a real mount so we never silently write into an empty /Volumes/T9 placeholder.
VOL_ROOT="$(printf '%s' "$DEST_ROOT" | sed -E 's#^(/Volumes/[^/]+).*#\1#')"
if [[ "$VOL_ROOT" == /Volumes/* ]] && ! mount | grep -q " on ${VOL_ROOT} "; then
  err "Drive not mounted at ${VOL_ROOT}. Plug in the T9 (or pass a different destination root)."
  exit 1
fi

DRY_RUN=0
[[ -n "${DRYRUN[*]-}" ]] && DRY_RUN=1

if [[ "$DRY_RUN" -eq 0 ]]; then
  mkdir -p "$DEST_ROOT"
fi
if [[ -d "$DEST_ROOT" ]]; then
  REAL_DEST_ROOT="$(cd "$DEST_ROOT" && pwd -P)"
else
  # --dry-run against a destination root that doesn't exist yet — nothing to
  # resolve to; fall back to the literal path (no realpath guard possible).
  REAL_DEST_ROOT="$DEST_ROOT"
fi

# 3. Per-folder exclude lists (mirrors os/macos/sync-to-new-mac.sh) ----------
excludes_for() {
  case "$1" in
    Developer)
      # Regenerable deps/build/cache dirs are skipped; .git, .env* kept.
      printf '%s\n' node_modules .next .nuxt .svelte-kit .turbo .cache .parcel-cache \
        dist build out coverage target vendor .venv venv __pycache__ \
        .pytest_cache .mypy_cache Pods .gradle .DS_Store
      ;;
    .ssh)
      # Live agent socket can't be copied.
      printf '%s\n' agent .DS_Store
      ;;
    .claude)
      printf '%s\n' cache paste-cache shell-snapshots backups telemetry plugins .DS_Store
      ;;
    .codex)
      printf '%s\n' plugins computer-use log cache 'logs_2.sqlite*' models_cache.json \
        .tmp tmp ipc process_manager '..codex-global-state.json.tmp-*' .DS_Store
      ;;
    .config)
      # Regenerable: gcloud's bundled venv, and zsh/tmux plugins cloned from git.
      printf '%s\n' gcloud/virtenv zsh/plugins tmux/plugins .DS_Store
      ;;
    .anydesk)
      printf '%s\n' cache global_cache thumbnails '*.trace' .DS_Store
      ;;
    .pgadmin)
      printf '%s\n' 'pgadmin4.log*' sessions azurecredentialcache .DS_Store
      ;;
    Pictures)
      # Photos Library is huge and managed by Photos.app — not a plain file dump.
      printf '%s\n' 'Photos Library.photoslibrary' .DS_Store
      ;;
    Music)
      # Music Library is huge and managed by Music.app — not a plain file dump.
      # Media.localized is just Finder display-name metadata (shows as "Media"), no audio in it.
      printf '%s\n' 'Music/Music Library.musiclibrary' 'Music/Media.localized' .DS_Store
      ;;
    *)
      printf '%s\n' .DS_Store
      ;;
  esac
}

RSYNC_FLAGS=(-rtD --no-perms --no-owner --no-group --modify-window=2 --human-readable)
if [[ -t 1 ]]; then
  # macOS ships openrsync (BSD, protocol 29) by default, which lacks the
  # GPL rsync 3.1+ --info=progress2 flag; probe for it instead of assuming.
  if rsync --info=progress2 --version >/dev/null 2>&1; then
    RSYNC_FLAGS+=(--info=progress2)
  else
    RSYNC_FLAGS+=(--progress)
  fi
fi

# 4. Sync one folder ----------------------------------------------------------
sync_folder() {
  local name="$1" src dest exclude_args=()
  src="$HOME/$name"
  dest="$DEST_ROOT/$name"

  if [[ ! -d "$src" ]]; then
    warn "Skipping ${name}: $src not found"
    return 0
  fi

  local real_dest
  if [[ "$DRY_RUN" -eq 0 ]]; then
    mkdir -p "$dest"
    real_dest="$(cd "$dest" && pwd -P)"
  elif [[ -d "$dest" ]]; then
    real_dest="$(cd "$dest" && pwd -P)"
  else
    real_dest="$REAL_DEST_ROOT/$name"
  fi

  # Guard: destination must still resolve inside the destination root (blocks
  # a symlink escape from turning --delete into deleting something else).
  if [[ "$real_dest" != "$REAL_DEST_ROOT" && "$real_dest" != "$REAL_DEST_ROOT"/* ]]; then
    err "Skipping ${name}: destination $real_dest escapes $REAL_DEST_ROOT"
    return 1
  fi

  # Guard: never let source and destination be the same path (would make
  # --delete erase the very thing it's backing up).
  local real_src
  real_src="$(cd "$src" && pwd -P)"
  if [[ "$real_src" == "$real_dest" ]]; then
    err "Skipping ${name}: source and destination are the same path ($real_src)"
    return 1
  fi

  # Guard: don't mirror an empty source over an existing backup — almost
  # always means "not mounted" rather than "really delete everything".
  if [[ -n "${DELETE[*]-}" ]] && [[ -z "$(ls -A "$src" 2>/dev/null)" ]]; then
    warn "Skipping ${name}: source is empty — refusing to mirror-delete its T9 copy"
    return 0
  fi

  while IFS= read -r pattern; do
    exclude_args+=(--exclude "$pattern")
  done < <(excludes_for "$name")

  info "Backing up ${src} → ${dest}"
  if rsync "${RSYNC_FLAGS[@]}" \
       ${DRYRUN[@]+"${DRYRUN[@]}"} ${DELETE[@]+"${DELETE[@]}"} \
       "${exclude_args[@]}" "$src/" "$dest/"; then
    ok "${name} synced"
  else
    # exit 23/24 = some files skipped (e.g. symlinks on exFAT); the copy still ran.
    local rc=$?
    if [[ $rc -eq 23 || $rc -eq 24 ]]; then
      warn "${name} finished with skipped items (exit $rc) — usually symlinks that exFAT can't store. Files copied."
    else
      err "${name} rsync failed (exit $rc)."
      return $rc
    fi
  fi
}

# 5. Run ----------------------------------------------------------------------
info "Destination root: ${DEST_ROOT}${MIRRORING}"
FAILED=0
for name in "${FOLDERS[@]}"; do
  sync_folder "$name" || FAILED=1
done

# ~/.claude.json is a single file living alongside ~/.claude/, not inside it.
for name in "${FOLDERS[@]}"; do
  if [[ "$name" == ".claude" && -f "$HOME/.claude.json" ]]; then
    info "Backing up ~/.claude.json…"
    if rsync "${RSYNC_FLAGS[@]}" ${DRYRUN[@]+"${DRYRUN[@]}"} \
         "$HOME/.claude.json" "$DEST_ROOT/.claude.json"; then
      ok ".claude.json synced"
    else
      warn ".claude.json sync failed — continuing"
    fi
    break
  fi
done

echo
if [[ "$FAILED" -eq 0 ]]; then
  ok "Backup complete → ${DEST_ROOT}"
else
  err "Backup finished with errors — see above."
  exit 1
fi
