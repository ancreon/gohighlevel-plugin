---
name: gohighlevel
description: >
  This skill manages GoHighLevel (GHL) agency sub-accounts via the API v2 — automations, tags, custom fields/values, calendars, scheduling, products, and contacts with per-client isolation. Use this skill whenever the user mentions "GoHighLevel", "GHL", "HighLevel", "sub-accounts", "client setup in GHL", "set up automations", "create tags for client", "manage calendars in HighLevel", "add products to GHL", "custom fields", "custom values", "GHL API", "client onboarding", or any request to read or write data in a GoHighLevel sub-account. Always use this skill for any GHL-related work — do not try to call the GHL API from memory.
---

# GoHighLevel API Skill

You are helping manage GoHighLevel agency sub-accounts via the GHL API v2. This plugin is built and maintained by Chris Barber at Abiding Agency (abidingagency.com).

## Architecture Overview

This skill uses a **secure, client-scoped** approach:

- **Agency API key** stored in a `.env` file (never hardcoded, never committed)
- **Client config** maps friendly client names to their GHL sub-account (location) IDs
- **All API calls are scoped** to a specific client's sub-account — you physically cannot accidentally touch the wrong client's data

## Before Making Any API Call

1. **Load credentials**: Read the `.env` file at `~/.ghl/credentials.env` to get the agency API key
2. **Load client config**: Read `~/.ghl/clients.json` to get the client's location ID
3. **Confirm the client**: Always confirm which client you're working with before making API calls. If ambiguous, ask.
4. **Use the helper script**: All API calls go through `scripts/ghl-api.sh` which handles auth headers, client scoping, and error handling

## Credential Files

### ~/.ghl/credentials.env
```
GHL_AGENCY_API_KEY=your-agency-api-key-here
```

### ~/.ghl/clients.json
```json
{
  "clients": {
    "client-name": {
      "name": "Client Display Name",
      "locationId": "location-id-from-ghl",
      "notes": "Optional notes about this client"
    }
  }
}
```

If these files don't exist, guide the user through first-time setup (see Setup section below).

## API Basics

**Base URL**: `https://services.leadconnectorhq.com`

**Required headers on every request**:
```
Authorization: Bearer {api_key}
Version: 2021-04-15
Content-Type: application/json
```

**Client scoping**: Pass `locationId` as a query parameter or in the request body to scope requests to a specific sub-account.

**Rate limits**: 100 requests per 10 seconds, 200,000 per day. Monitor `X-RateLimit-Remaining` header.

## Core Operations

### Contacts
Read `references/contacts.md` for full endpoint details.
- Search/list contacts: `GET /contacts/search?locationId={id}`
- Create contact: `POST /contacts` with `locationId` in body
- Update contact: `PUT /contacts/{contactId}`
- Add tags to contact: `POST /contacts/{contactId}/tags`

### Tags
Read `references/tags.md` for full endpoint details.
- List tags: `GET /tags?locationId={id}`
- Create tag: `POST /tags` with `name` and `locationId`
- Add tag to contact: `POST /contacts/{contactId}/tags`

### Custom Fields & Custom Values
Read `references/custom-fields.md` for full endpoint details.
- List custom fields: `GET /custom-fields?locationId={id}`
- Create custom field: `POST /custom-fields`
- Set custom value on contact: include in contact create/update via `customFields` object

### Automations / Workflows
Read `references/workflows.md` for full endpoint details.
- List workflows: `GET /workflows?locationId={id}`
- Get workflow: `GET /workflows/{workflowId}`
- Trigger workflow: `POST /workflows/{workflowId}/trigger`

### Calendars & Scheduling
Read `references/calendars.md` for full endpoint details.
- List calendars: `GET /calendars?locationId={id}`
- Create calendar: `POST /calendars`
- List appointments: `GET /calendars/{calendarId}/appointments`
- Create appointment: `POST /calendars/{calendarId}/appointments`

### Products & Pricing
Read `references/products.md` for full endpoint details.
- List products: `GET /products?locationId={id}`
- Create product: `POST /products`
- Create price: `POST /products/{productId}/prices`

### Sub-Accounts (Locations)
Read `references/locations.md` for full endpoint details.
- List all sub-accounts: `GET /locations` (agency key required)
- Get sub-account details: `GET /locations/{locationId}`

## Making API Calls

Use the helper script for all API calls:

```bash
# GET request
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh GET "/contacts/search?locationId={locationId}&limit=20"

# POST request
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh POST "/contacts" '{"firstName":"John","lastName":"Doe","email":"john@example.com","locationId":"abc123"}'

# PUT request
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh PUT "/contacts/{contactId}" '{"firstName":"Updated"}'

# DELETE request
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh DELETE "/tags/{tagId}"
```

The script automatically:
- Loads the API key from `~/.ghl/credentials.env`
- Adds required auth and version headers
- Handles JSON content type
- Returns formatted JSON responses
- Shows HTTP status codes for debugging

## First-Time Setup

If `~/.ghl/` doesn't exist, walk the user through this:

1. **Create the secure directory**:
   ```bash
   mkdir -p ~/.ghl && chmod 700 ~/.ghl
   ```

2. **Get the Agency API key**: Guide the user to GHL Settings > Business Profile > API Keys (or Agency Settings > API). An Agency Pro plan is required for cross-sub-account access.

3. **Create credentials.env**:
   ```bash
   echo "GHL_AGENCY_API_KEY=paste-key-here" > ~/.ghl/credentials.env
   chmod 600 ~/.ghl/credentials.env
   ```

4. **Discover sub-accounts**: Once the key is set, run:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-api.sh GET "/locations"
   ```
   This returns all sub-accounts. Use the output to build `clients.json`.

5. **Create clients.json** from the discovered sub-accounts.

6. **Test**: Run a simple contacts search for one client to verify everything works.

## Security Rules

- NEVER echo, log, or display the API key in responses to the user
- NEVER include API keys in code blocks shown to the user
- NEVER commit credentials files to any repository
- Always confirm which client before making write operations (POST, PUT, DELETE)
- The `~/.ghl/` directory uses 700 permissions (owner-only access)
- The `credentials.env` file uses 600 permissions (owner read/write only)
- If the user asks to see their config, show `clients.json` (safe) but NEVER show `credentials.env` contents

## Error Handling

- **401 Unauthorized**: API key is invalid or expired. Guide user to regenerate.
- **403 Forbidden**: The key doesn't have access to that sub-account. Check locationId.
- **404 Not Found**: Resource doesn't exist. Double-check IDs.
- **422 Unprocessable Entity**: Bad request body. Check required fields.
- **429 Too Many Requests**: Rate limited. Wait and retry with backoff.

## Usage Tips

- You can say things like "show me all tags for ClientX" or "create a calendar called Discovery Call for ClientY"
- When onboarding a new client, start with: create tags, set up custom fields, create calendars, then build automations
- Use `--dry-run` flag with the helper script to preview requests without sending them
- The skill loads reference docs on demand — ask about any specific API area and I'll pull up the details
