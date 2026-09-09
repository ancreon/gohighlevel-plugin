#!/usr/bin/env bash
# GoHighLevel API Helper Script
# Usage: bash ghl-api.sh METHOD ENDPOINT [BODY] [--dry-run] [--token TOKEN_VAR]
#
# Examples:
#   bash ghl-api.sh GET "/locations/search"
#   bash ghl-api.sh GET "/locations/abc123/tags" --token GHL_TOKEN_ACME
#   bash ghl-api.sh POST "/contacts" '{"firstName":"John","locationId":"abc123"}' --token GHL_TOKEN_ACME
#   bash ghl-api.sh GET "/locations" --dry-run
#
# Token selection:
#   --token VAR_NAME   Use a specific token variable from credentials.env
#                      If not specified, falls back to GHL_AGENCY_API_KEY
#
# Environment:
#   Reads credentials from the config dir resolved by lib-ghl-config.sh:
#   $GHL_CONFIG_DIR, else ~/.ghl, else a mounted */ghl-config folder.
#   Requires: curl, jq (optional, for pretty output)

set -euo pipefail

BASE_URL="https://services.leadconnectorhq.com"
API_VERSION="2021-07-28"

# Resolve config location via the shared lib ($GHL_CONFIG_DIR -> ~/.ghl -> mounted */ghl-config)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-ghl-config.sh"
GHL_DIR="$(ghl_config_dir credentials.env || true)"
[[ -z "$GHL_DIR" ]] && GHL_DIR="$(ghl_target_dir)"  # for the not-found message below
CREDS_FILE="$GHL_DIR/credentials.env"

# --- Argument parsing ---
METHOD="${1:-}"
ENDPOINT="${2:-}"
BODY=""
DRY_RUN=false
TOKEN_VAR=""

# Parse arguments after METHOD and ENDPOINT
shift 2 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --token)
      TOKEN_VAR="${2:-}"
      shift 2
      ;;
    *)
      if [[ -z "$BODY" ]]; then
        BODY="$1"
      fi
      shift
      ;;
  esac
done

# --- Validation ---
if [[ -z "$METHOD" || -z "$ENDPOINT" ]]; then
  echo "GoHighLevel API Helper"
  echo ""
  echo "Usage: bash ghl-api.sh METHOD ENDPOINT [BODY] [--dry-run] [--token VAR]"
  echo ""
  echo "Methods: GET, POST, PUT, DELETE, PATCH"
  echo ""
  echo "Examples:"
  echo "  bash ghl-api.sh GET \"/locations/search\""
  echo "  bash ghl-api.sh GET \"/locations/abc123/tags\" --token GHL_TOKEN_ACME"
  echo "  bash ghl-api.sh POST \"/contacts\" '{\"firstName\":\"John\"}' --token GHL_TOKEN_ACME"
  echo "  bash ghl-api.sh GET \"/locations\" --dry-run"
  echo ""
  echo "Config dir (resolved): $GHL_DIR"
  echo "  Order: \$GHL_CONFIG_DIR -> ~/.ghl -> mounted */ghl-config"
  exit 1
fi

METHOD=$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')

# --- Load credentials ---
if [[ ! -f "$CREDS_FILE" ]]; then
  echo "ERROR: Credentials file not found at $CREDS_FILE"
  echo ""
  echo "Config is resolved in this order:"
  echo "  1. \$GHL_CONFIG_DIR (if set)   2. ~/.ghl   3. a mounted */ghl-config folder"
  echo ""
  echo "First-time setup (run /ghl-setup, or manually):"
  echo "  mkdir -p \"$GHL_DIR\" && chmod 700 \"$GHL_DIR\""
  echo "  echo \"GHL_AGENCY_API_KEY=your-key-here\" > \"$GHL_DIR/credentials.env\""
  echo "  chmod 600 \"$GHL_DIR/credentials.env\""
  exit 1
fi

# Source the credentials file
source "$CREDS_FILE"

# Select the right token
if [[ -n "$TOKEN_VAR" ]]; then
  API_TOKEN="${!TOKEN_VAR:-}"
  if [[ -z "$API_TOKEN" ]]; then
    echo "ERROR: Token variable '$TOKEN_VAR' not found in $CREDS_FILE"
    echo "Available tokens:"
    grep -o '^GHL_[A-Z_]*=' "$CREDS_FILE" | sed 's/=$/  /' || true
    exit 1
  fi
elif [[ -n "${GHL_AGENCY_API_KEY:-}" ]]; then
  API_TOKEN="${GHL_AGENCY_API_KEY}"
else
  echo "ERROR: No API token available. Set GHL_AGENCY_API_KEY or use --token."
  exit 1
fi

# --- Build the curl command ---
URL="${BASE_URL}${ENDPOINT}"

CURL_ARGS=(
  -s
  -w "\n--- HTTP Status: %{http_code} ---\n"
  -X "$METHOD"
  -H "Authorization: Bearer ${API_TOKEN}"
  -H "Version: ${API_VERSION}"
  -H "Content-Type: application/json"
  -H "Accept: application/json"
  -H "User-Agent: ${GHL_USER_AGENT:-gohighlevel-plugin/0.3.0}"
)

if [[ -n "$BODY" ]]; then
  CURL_ARGS+=(-d "$BODY")
fi

# --- Dry run mode ---
if [[ "$DRY_RUN" == true ]]; then
  echo "=== DRY RUN ==="
  echo "Method:   $METHOD"
  echo "URL:      $URL"
  echo "Token:    ${TOKEN_VAR:-GHL_AGENCY_API_KEY} (***REDACTED***)"
  echo "Headers:"
  echo "  Authorization: Bearer ***REDACTED***"
  echo "  Version: $API_VERSION"
  echo "  Content-Type: application/json"
  if [[ -n "$BODY" ]]; then
    echo "Body:"
    if command -v jq &>/dev/null; then
      echo "$BODY" | jq . 2>/dev/null || echo "  $BODY"
    else
      echo "  $BODY"
    fi
  fi
  echo "================"
  echo "(No request sent)"
  exit 0
fi

# --- Execute ---
RESPONSE=$(curl "${CURL_ARGS[@]}" "$URL")

# Pretty-print JSON if jq is available
if command -v jq &>/dev/null; then
  # Separate the status line from the JSON body
  JSON_BODY=$(echo "$RESPONSE" | head -n -1)
  STATUS_LINE=$(echo "$RESPONSE" | tail -n 1)

  echo "$JSON_BODY" | jq . 2>/dev/null || echo "$JSON_BODY"
  echo "$STATUS_LINE"
else
  echo "$RESPONSE"
fi
