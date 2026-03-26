#!/usr/bin/env bash
# GoHighLevel API Helper Script
# Usage: bash ghl-api.sh METHOD ENDPOINT [BODY] [--dry-run]
#
# Examples:
#   bash ghl-api.sh GET "/contacts/search?locationId=abc123&limit=20"
#   bash ghl-api.sh POST "/contacts" '{"firstName":"John","locationId":"abc123"}'
#   bash ghl-api.sh PUT "/contacts/xyz" '{"firstName":"Updated"}'
#   bash ghl-api.sh DELETE "/tags/tag123"
#   bash ghl-api.sh GET "/locations" --dry-run
#
# Environment:
#   Reads API key from ~/.ghl/credentials.env
#   Requires: curl, jq (optional, for pretty output)

set -euo pipefail

BASE_URL="https://services.leadconnectorhq.com"
CREDS_FILE="$HOME/.ghl/credentials.env"
API_VERSION="2021-04-15"

# --- Argument parsing ---
METHOD="${1:-}"
ENDPOINT="${2:-}"
BODY="${3:-}"
DRY_RUN=false

# Check for --dry-run in any position
for arg in "$@"; do
  if [[ "$arg" == "--dry-run" ]]; then
    DRY_RUN=true
  fi
done

# --- Validation ---
if [[ -z "$METHOD" || -z "$ENDPOINT" ]]; then
  echo "GoHighLevel API Helper"
  echo ""
  echo "Usage: bash ghl-api.sh METHOD ENDPOINT [BODY] [--dry-run]"
  echo ""
  echo "Methods: GET, POST, PUT, DELETE, PATCH"
  echo ""
  echo "Examples:"
  echo "  bash ghl-api.sh GET \"/locations\""
  echo "  bash ghl-api.sh GET \"/contacts/search?locationId=abc123&limit=20\""
  echo "  bash ghl-api.sh POST \"/contacts\" '{\"firstName\":\"John\",\"locationId\":\"abc123\"}'"
  echo "  bash ghl-api.sh GET \"/tags?locationId=abc123\" --dry-run"
  echo ""
  echo "Config:"
  echo "  API key:   ~/.ghl/credentials.env"
  echo "  Clients:   ~/.ghl/clients.json"
  exit 1
fi

METHOD=$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')

# --- Load credentials ---
if [[ ! -f "$CREDS_FILE" ]]; then
  echo "ERROR: Credentials file not found at $CREDS_FILE"
  echo ""
  echo "First-time setup:"
  echo "  mkdir -p ~/.ghl && chmod 700 ~/.ghl"
  echo "  echo \"GHL_AGENCY_API_KEY=your-key-here\" > ~/.ghl/credentials.env"
  echo "  chmod 600 ~/.ghl/credentials.env"
  exit 1
fi

# Source the credentials file
source "$CREDS_FILE"

if [[ -z "${GHL_AGENCY_API_KEY:-}" ]]; then
  echo "ERROR: GHL_AGENCY_API_KEY not set in $CREDS_FILE"
  exit 1
fi

# --- Build the curl command ---
URL="${BASE_URL}${ENDPOINT}"

CURL_ARGS=(
  -s
  -w "\n--- HTTP Status: %{http_code} ---\n"
  -X "$METHOD"
  -H "Authorization: Bearer ${GHL_AGENCY_API_KEY}"
  -H "Version: ${API_VERSION}"
  -H "Content-Type: application/json"
  -H "Accept: application/json"
)

if [[ -n "$BODY" && "$BODY" != "--dry-run" ]]; then
  CURL_ARGS+=(-d "$BODY")
fi

# --- Dry run mode ---
if [[ "$DRY_RUN" == true ]]; then
  echo "=== DRY RUN ==="
  echo "Method:   $METHOD"
  echo "URL:      $URL"
  echo "Headers:"
  echo "  Authorization: Bearer ***REDACTED***"
  echo "  Version: $API_VERSION"
  echo "  Content-Type: application/json"
  if [[ -n "$BODY" && "$BODY" != "--dry-run" ]]; then
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
