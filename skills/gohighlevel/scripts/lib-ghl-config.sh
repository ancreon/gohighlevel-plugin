#!/usr/bin/env bash
# Shared GoHighLevel config-location resolver.
# Sourced by ghl-api.sh and ghl-client.sh so reading and writing config always
# agree on a single location. Do not run directly.
#
# Resolution order (most explicit first):
#   1. $GHL_CONFIG_DIR        — explicit override, works in any environment
#   2. ~/.ghl                 — default for Claude Code / desktop (persistent home)
#   3. a mounted */ghl-config — Cowork sandbox, where ~ is wiped between sessions
#                               so config must live in a folder mounted from the
#                               user's real computer. Also accepts */.ghl.

# ghl_config_dir [marker]
# Echoes the config dir. An explicit $GHL_CONFIG_DIR always wins (whether or not
# it is populated yet) so the override is predictable. Otherwise echoes the dir
# that CURRENTLY holds `marker` (default credentials.env), returning non-zero if
# no existing config is found.
ghl_config_dir() {
  local marker="${1:-credentials.env}"
  if [[ -n "${GHL_CONFIG_DIR:-}" ]]; then
    printf '%s\n' "$GHL_CONFIG_DIR"; return 0
  fi
  if [[ -f "$HOME/.ghl/${marker}" ]]; then
    printf '%s\n' "$HOME/.ghl"; return 0
  fi
  local d
  for d in /sessions/*/mnt/*/ghl-config /sessions/*/mnt/*/.ghl; do
    [[ -f "${d}/${marker}" ]] && { printf '%s\n' "$d"; return 0; }
  done
  return 1
}

# ghl_target_dir
# Echoes the dir where NEW config should be created during setup (creates nothing).
# Prefers an explicit override, then any existing config dir, then a durable
# mounted folder in Cowork, falling back to ~/.ghl.
ghl_target_dir() {
  if [[ -n "${GHL_CONFIG_DIR:-}" ]]; then
    printf '%s\n' "$GHL_CONFIG_DIR"; return 0
  fi
  local existing
  existing=$(ghl_config_dir credentials.env) && { printf '%s\n' "$existing"; return 0; }
  existing=$(ghl_config_dir clients.json) && { printf '%s\n' "$existing"; return 0; }
  # Cowork sandbox: prefer a mounted folder so config survives between sessions.
  local mnt
  mnt=$(ls -d /sessions/*/mnt/*/ 2>/dev/null | head -n1)
  if [[ -n "$mnt" ]]; then
    printf '%s\n' "${mnt%/}/ghl-config"; return 0
  fi
  printf '%s\n' "$HOME/.ghl"; return 0
}
