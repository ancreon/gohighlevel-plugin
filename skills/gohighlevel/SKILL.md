---
name: gohighlevel
description: >
  This skill manages GoHighLevel (GHL) agency sub-accounts via the API v2 — tags, custom fields/values, calendars, scheduling, products, contacts, and workflows (read/trigger only) with per-client isolation. Use this skill whenever the user mentions "GoHighLevel", "GHL", "HighLevel", "sub-accounts", "client setup in GHL", "create tags for client", "manage calendars in HighLevel", "add products to GHL", "custom fields", "custom values", "GHL API", "client onboarding", "list workflows", "trigger workflow", or any request to read or write data in a GoHighLevel sub-account. Always use this skill for any GHL-related work — do not try to call the GHL API from memory.
---

# GoHighLevel API Skill

You are helping manage GoHighLevel agency sub-accounts via the GHL API v2. This plugin is built and maintained by Chris Barber at Abiding Agency (abidingagency.com).

## Architecture Overview

This skill uses a **two-tier token system** with per-client isolation:

- **Agency API key** — used for agency-level operations (listing sub-accounts, managing locations)
- **Sub-account tokens** — one per client, used for all client-scoped operations (contacts, tags, calendars, etc.)
- **Client config** maps friendly client names to their location IDs and token variable names

This separation exists because GHL scopes API permissions differently at the agency vs. sub-account level. Agency tokens can manage locations but cannot access contacts, tags, or calendars. Sub-account tokens have full access to that specific client's data.

**Sub-account-only users**: If the user does not have agency access (e.g., they only manage a single GHL sub-account), the plugin still works. They skip the agency key, generate a Location-level PIT from their sub-account settings, and configure a single client entry. The only features they lose are agency-level endpoints like `/locations/search`.

## Config Location

The helper scripts resolve where `credentials.env` and `clients.json` live, in this order:

1. **`$GHL_CONFIG_DIR`** — explicit override; works in any environment
2. **`~/.ghl/`** — default for Claude Code / desktop (persistent home directory)
3. **a mounted `*/ghl-config` folder** — used in Cowork, where the sandbox home is wiped between sessions, so config must live in a folder mounted from the user's real computer

Never hardcode the path — always go through the helper scripts (or read the dir they report). To find the resolved dir, run `ghl-api.sh` with no arguments; it prints "Config dir (resolved): …".

## Before Making Any API Call

1. **Load client config**: Read `clients.json` from the resolved config dir to get the client's `locationId` and `tokenVar`
2. **Confirm the client**: Always confirm which client you're working with before making API calls. If ambiguous, ask.
3. **Choose the right token**:
   - Agency-level calls (list locations, manage sub-accounts): use `GHL_AGENCY_API_KEY`
   - Client-scoped calls (contacts, tags, calendars, etc.): use the client's `tokenVar`
4. **Use the helper script** with the `--token` flag for client-scoped calls

## Credential Files

### credentials.env
```
GHL_AGENCY_API_KEY=agency-key-here

# Sub-account tokens (one per client)
GHL_TOKEN_ACME=sub-account-token-here
```

### clients.json
```json
{
  "clients": {
    "acme": {
      "name": "Acme Corp",
      "locationId": "location-id-from-ghl",
      "tokenVar": "GHL_TOKEN_ACME",
      "notes": "Optional notes"
    }
  }
}
```

If these files don't exist, guide the user through first-time setup (see Setup section below).

## API Basics

**Base URL**: `https://services.leadconnectorhq.com`

**Required headers on every request**:
```
Authorization: Bearer {token}
Version: 2021-07-28
Content-Type: application/json
```

**Endpoint pattern for sub-account data**: GHL's API uses **mixed patterns** depending on the resource — some use path params, some use query params. This is GHL's design, not a bug:
- Path param style: `GET /locations/{locationId}/tags`, `GET /locations/{locationId}/customFields`
- Query param style: `GET /contacts/?locationId={locationId}`, `GET /workflows?locationId={id}`

Always check the reference doc for the specific resource to get the correct URL pattern.

**Rate limits**: 100 requests per 10 seconds, 200,000 per day. Monitor `X-RateLimit-Remaining` header.

## Core Operations

### Contacts
Read `references/contacts.md` for full endpoint details.
- List contacts: `GET /contacts/?locationId={id}&limit=20`
- Create contact: `POST /contacts` with `locationId` in body
- Update contact: `PUT /contacts/{contactId}`
- Add tags to contact: `POST /contacts/{contactId}/tags`

### Tags
Read `references/tags.md` for full endpoint details.
- List tags: `GET /locations/{locationId}/tags`
- Create tag: `POST /locations/{locationId}/tags` with `name` in body
- Add tag to contact: `POST /contacts/{contactId}/tags`

### Custom Fields & Custom Values
Read `references/custom-fields.md` for full endpoint details.
- List custom fields: `GET /locations/{locationId}/customFields`
- Create custom field: `POST /locations/{locationId}/customFields`

### Workflows (Read & Trigger Only)
Read `references/workflows.md` for full endpoint details.
- List workflows: `GET /workflows?locationId={id}`
- Get workflow: `GET /workflows/{workflowId}`

**Important**: The GHL Workflows API is read and trigger only — you can list workflows and add a contact to a workflow, but you **cannot** create, edit, or build workflow steps via API. If the user asks to "build an automation" or "create a workflow," direct them to do that in the GHL UI, then you can trigger it or list it here.

### Calendars & Scheduling
Read `references/calendars.md` for full endpoint details.
- List calendars: `GET /calendars?locationId={id}`
- Create calendar: `POST /calendars`
- List appointments: `GET /calendars/{calendarId}/appointments`

### Products & Pricing
Read `references/products.md` for full endpoint details.
- List products: `GET /products?locationId={id}`
- Create product: `POST /products`

### Sub-Accounts (Locations)
Read `references/locations.md` for full endpoint details.
- List all sub-accounts: `GET /locations/search` (agency key, no --token needed)
- Get sub-account details: `GET /locations/{locationId}`

## Making API Calls

Use the helper script for all API calls. For client-scoped calls, always pass `--token`:

```bash
# Agency-level call (uses GHL_AGENCY_API_KEY by default)
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh GET "/locations/search"

# Client-scoped call (uses the client's sub-account token)
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh GET "/locations/{locationId}/tags" --token GHL_TOKEN_CLIENT_NAME

# POST with body and client token
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh POST "/contacts" '{"firstName":"John","locationId":"abc123"}' --token GHL_TOKEN_CLIENT_NAME

# Dry run (preview without sending)
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh GET "/locations/{locationId}/tags" --token GHL_TOKEN_CLIENT_NAME --dry-run
```

### Typical call pattern for a client operation:

```bash
# 1. Look up the client's locationId (ghl-client.sh resolves the config dir for you)
LOCATION_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-client.sh get acme)

# 2. Make the scoped call (tokenVar follows the GHL_TOKEN_<KEY> convention)
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh GET "/locations/${LOCATION_ID}/tags" --token GHL_TOKEN_ACME
```

## First-Time Setup

If no config exists yet, run `/ghl-setup`, or walk the user through this. First decide where config should live (see Config Location above):
- **Claude Code / desktop**: `~/.ghl`
- **Cowork**: a folder mounted from the user's computer, e.g. `<their-mounted-folder>/ghl-config`, so it survives between sessions
- Or set `GHL_CONFIG_DIR` to any path you prefer

In the steps below, `$GHL_DIR` means that chosen directory.

1. **Create the secure directory**:
   ```bash
   mkdir -p "$GHL_DIR" && chmod 700 "$GHL_DIR"
   ```

2. **Get the Agency API key** (agency users): Guide the user to GHL Settings > Business Profile > API Keys. This key manages locations/sub-accounts. **Sub-account-only users** can skip this step — they won't have agency access and don't need `GHL_AGENCY_API_KEY`.

3. **Discover sub-accounts**: Use the agency key to list all locations.

4. **Create sub-account tokens**: For each client, go into that sub-account in GHL > Settings > Integrations > Private Integrations > Create. Enable all scopes. Save the token.

5. **Add tokens to credentials.env** — one `GHL_TOKEN_` variable per client.

6. **Build clients.json** — map each client key to locationId and tokenVar.

7. **Test**: Pull tags for a client to verify.

## Security Rules

- NEVER echo, log, or display API tokens in responses to the user
- NEVER include tokens in code blocks shown to the user
- NEVER commit credentials files to any repository
- Always confirm which client before making write operations (POST, PUT, DELETE)
- The config directory uses 700 permissions (owner-only access)
- The `credentials.env` file uses 600 permissions (owner read/write only)
- If the user asks to see their config, show `clients.json` (safe) but NEVER show `credentials.env` contents

## Error Handling

- **401 Unauthorized**: Token is invalid, expired, or missing required scopes. Most common cause: reusing a PIT from one sub-account to call a different sub-account — PITs are single-sub-account-scoped. Fix: generate a dedicated Location PIT inside the target sub-account's Settings > Integrations > Private Integrations.
- **403 Forbidden**: The token doesn't have access to that resource.
- **404 Not Found**: Resource or endpoint doesn't exist. Try the `/locations/{locationId}/resource` pattern.
- **422 Unprocessable Entity**: Bad request body. Check required fields.
- **429 Too Many Requests**: Rate limited. Wait and retry with backoff.

## Usage Tips

- Say things like "show me all tags for acme" or "create a calendar for acme"
- When onboarding a new client, start with: create tags, set up custom fields, create calendars, then build automations
- Use `--dry-run` to preview any request before sending
- If a client shows "Needs sub-account token" in notes, walk through creating a Private Integration in that sub-account first
