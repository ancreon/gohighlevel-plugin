---
description: Set up GHL credentials and client config
allowed-tools: Bash, Read, Write, Edit
---

Walk the user through first-time GoHighLevel API setup. This is an interactive process — go step by step and confirm each part before moving on.

## Step 1: Create secure directory

```bash
mkdir -p ~/.ghl && chmod 700 ~/.ghl
```

## Step 2: Get the Agency API key

Ask the user to go to their GHL account:
- Settings > Business Profile > API Keys (or Developer/API section)
- Generate a Private Integration token with agency-level access
- Have them paste the key (never echo it back)

Create the credentials file:
```bash
echo "GHL_AGENCY_API_KEY={the-key-they-provide}" > ~/.ghl/credentials.env
chmod 600 ~/.ghl/credentials.env
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
