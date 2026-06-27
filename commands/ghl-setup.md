---
description: Set up GHL credentials and client config
allowed-tools: Bash, Read, Write, Edit
---

Walk the user through first-time GoHighLevel API setup. This is an interactive process — go step by step and confirm each part before moving on.

## Step 0: Decide where config lives

Config is resolved by `lib-ghl-config.sh` in this order: `$GHL_CONFIG_DIR` → `~/.ghl` → a mounted `*/ghl-config` folder. Pick the durable location for this user's environment:

- **Claude Code / desktop**: use `~/.ghl`.
- **Cowork**: the sandbox home is wiped between sessions, so config MUST live in a folder the user has mounted from their computer. Ask which mounted folder to use, then use `<that-folder>/ghl-config`. Naming it exactly `ghl-config` is what lets the scripts auto-find it in later sessions (or set `GHL_CONFIG_DIR`). Confirm the choice before writing.

Set a shell variable for the chosen path and reuse it in the steps below:
```bash
GHL_DIR="$HOME/.ghl"   # or e.g. "/path/to/mounted-folder/ghl-config" in Cowork
```

## Step 1: Create secure directory

```bash
mkdir -p "$GHL_DIR" && chmod 700 "$GHL_DIR"
```

## Step 2: Get the Agency API key

Ask the user to go to their GHL account:
- Settings > Business Profile > API Keys (or Developer/API section)
- Generate a Private Integration token with agency-level access
- Have them paste the key (never echo it back)

Create the credentials file:
```bash
echo "GHL_AGENCY_API_KEY={the-key-they-provide}" > "$GHL_DIR/credentials.env"
chmod 600 "$GHL_DIR/credentials.env"
```

## Step 3: Discover sub-accounts

Run:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh GET "/locations"
```

Show the user their sub-accounts and help them build the clients config.

## Step 4: Create clients.json

For each client they want to add:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-client.sh add <key> "<name>" <location-id>
```

## Step 5: Verify

Run a test API call for one client to confirm everything works:
```bash
LOCATION_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-client.sh get <client-key>)
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh GET "/tags?locationId=${LOCATION_ID}"
```

Confirm success and let the user know they're all set.
