#!/usr/bin/env bash
# GoHighLevel Client Manager
# Lookup client locationId from clients.json (location resolved by lib-ghl-config.sh)
#
# Usage:
#   bash ghl-client.sh list                    # List all configured clients
#   bash ghl-client.sh get <client-name>       # Get locationId for a client
#   bash ghl-client.sh add <key> <name> <id>   # Add a new client
#   bash ghl-client.sh remove <client-key>     # Remove a client
#   bash ghl-client.sh discover                # Discover sub-accounts from API

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Resolve config location via the shared lib ($GHL_CONFIG_DIR -> ~/.ghl -> mounted */ghl-config)
source "$SCRIPT_DIR/lib-ghl-config.sh"
GHL_DIR="$(ghl_config_dir clients.json || true)"
[[ -z "$GHL_DIR" ]] && GHL_DIR="$(ghl_target_dir)"  # where config would be created
CLIENTS_FILE="$GHL_DIR/clients.json"

# --- Ensure jq is available ---
if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required. Install with: sudo apt install jq"
  exit 1
fi

ACTION="${1:-}"

case "$ACTION" in
  list)
    if [[ ! -f "$CLIENTS_FILE" ]]; then
      echo "No clients configured yet."
      echo "Run: bash ghl-client.sh discover"
      exit 0
    fi
    echo "Configured clients:"
    echo ""
    jq -r '.clients | to_entries[] | "  \(.key)\n    Name: \(.value.name)\n    Location ID: \(.value.locationId)\n    Notes: \(.value.notes // "none")\n"' "$CLIENTS_FILE"
    ;;

  get)
    CLIENT_KEY="${2:-}"
    if [[ -z "$CLIENT_KEY" ]]; then
      echo "Usage: bash ghl-client.sh get <client-name>"
      exit 1
    fi
    if [[ ! -f "$CLIENTS_FILE" ]]; then
      echo "ERROR: No clients file. Run: bash ghl-client.sh discover"
      exit 1
    fi
    LOCATION_ID=$(jq -r --arg key "$CLIENT_KEY" '.clients[$key].locationId // empty' "$CLIENTS_FILE")
    if [[ -z "$LOCATION_ID" ]]; then
      echo "ERROR: Client '$CLIENT_KEY' not found."
      echo ""
      echo "Available clients:"
      jq -r '.clients | keys[]' "$CLIENTS_FILE" | sed 's/^/  /'
      exit 1
    fi
    echo "$LOCATION_ID"
    ;;

  add)
    CLIENT_KEY="${2:-}"
    CLIENT_NAME="${3:-}"
    LOCATION_ID="${4:-}"
    if [[ -z "$CLIENT_KEY" || -z "$CLIENT_NAME" || -z "$LOCATION_ID" ]]; then
      echo "Usage: bash ghl-client.sh add <key> <display-name> <location-id>"
      echo "Example: bash ghl-client.sh add acme \"Acme Corp\" abc123def456"
      exit 1
    fi
    if [[ ! -f "$CLIENTS_FILE" ]]; then
      mkdir -p "$GHL_DIR" && chmod 700 "$GHL_DIR"
      echo '{"clients":{}}' > "$CLIENTS_FILE"
      chmod 600 "$CLIENTS_FILE"
    fi
    UPDATED=$(jq --arg key "$CLIENT_KEY" --arg name "$CLIENT_NAME" --arg id "$LOCATION_ID" \
      '.clients[$key] = {"name": $name, "locationId": $id, "notes": ""}' "$CLIENTS_FILE")
    echo "$UPDATED" > "$CLIENTS_FILE"
    echo "Added client: $CLIENT_KEY ($CLIENT_NAME)"
    ;;

  remove)
    CLIENT_KEY="${2:-}"
    if [[ -z "$CLIENT_KEY" ]]; then
      echo "Usage: bash ghl-client.sh remove <client-key>"
      exit 1
    fi
    if [[ ! -f "$CLIENTS_FILE" ]]; then
      echo "ERROR: No clients file."
      exit 1
    fi
    UPDATED=$(jq --arg key "$CLIENT_KEY" 'del(.clients[$key])' "$CLIENTS_FILE")
    echo "$UPDATED" > "$CLIENTS_FILE"
    echo "Removed client: $CLIENT_KEY"
    ;;

  discover)
    echo "Discovering sub-accounts from GHL API..."
    echo ""
    RESPONSE=$(bash "$SCRIPT_DIR/ghl-api.sh" GET "/locations" 2>&1)

    # Check for errors
    if echo "$RESPONSE" | grep -q "ERROR:"; then
      echo "$RESPONSE"
      exit 1
    fi

    # Parse and display
    echo "Found sub-accounts:"
    echo ""
    echo "$RESPONSE" | head -n -1 | jq -r '.locations[]? | "  ID: \(.id)\n  Name: \(.name)\n  Email: \(.email // "n/a")\n"' 2>/dev/null || echo "$RESPONSE"
    echo ""
    echo "To add a client, run:"
    echo "  bash ghl-client.sh add <short-key> \"<Display Name>\" <location-id>"
    ;;

  *)
    echo "GoHighLevel Client Manager"
    echo ""
    echo "Usage:"
    echo "  bash ghl-client.sh list              List configured clients"
    echo "  bash ghl-client.sh get <name>         Get locationId for a client"
    echo "  bash ghl-client.sh add <key> <name> <id>  Add a client"
    echo "  bash ghl-client.sh remove <key>       Remove a client"
    echo "  bash ghl-client.sh discover           Discover sub-accounts from API"
    ;;
esac
