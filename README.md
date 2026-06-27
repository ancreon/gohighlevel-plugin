# GoHighLevel Plugin for Claude Cowork & Claude Code

Built by [Chris Barber](https://github.com/ancreon) at [Abiding Agency](https://abidingagency.com)

Manage your GoHighLevel sub-accounts via API from any Claude session. Supports tags, custom fields/values, calendars, scheduling, products, contacts, and workflows (read/trigger) — all with per-client isolation.

## Quick Install

```
/plugin marketplace add ancreon/gohighlevel-plugin
/plugin install gohighlevel@gohighlevel-plugin
```

Then run `/ghl-setup` to configure your credentials.

## Components

| Type | Name | Purpose |
|------|------|---------|
| Skill | `gohighlevel` | API knowledge and usage patterns for all GHL endpoints |
| Command | `/ghl-setup` | Interactive first-time credential and client setup |
| Command | `/ghl-clients` | List, add, or remove client configurations |

## Setup

### For Agency Users (multiple sub-accounts)

**You need:**
1. A GoHighLevel Agency account with API access
2. An Agency API key (Private Integration token) for agency-level operations
3. A Location-level PIT for each sub-account you want to manage

**First-time setup:** Run `/ghl-setup` in any Claude session to walk through:
1. Creating the secure config directory (see [Config Location](#config-location))
2. Storing your Agency API key in `credentials.env`
3. Discovering your sub-accounts via the API
4. Generating a Location PIT for each sub-account
5. Configuring your client list in `clients.json`

### For Sub-Account Users (single account, no agency access)

**You need:**
1. Admin access to your GHL sub-account
2. A Location-level Private Integration Token (PIT) from your sub-account settings

**First-time setup:** Run `/ghl-setup` and:
1. Skip the Agency API key step (leave `GHL_AGENCY_API_KEY` blank or omit it)
2. Generate a PIT from your sub-account: Settings > Integrations > Private Integrations > Create
3. Enable all scopes you need, save the token
4. Add one entry to `clients.json` with your `locationId` and token variable

You'll have access to everything except agency-level endpoints like `/locations/search` (listing all sub-accounts). Since you only have one sub-account, you don't need those anyway.

## Usage

Once set up, just mention GHL in conversation:
- "Show me all tags for acme"
- "Create a Discovery Call calendar for client-x"
- "List custom fields for client-y"
- "Add a new product for client-z"
- "List workflows for client-z"

The skill automatically loads reference docs for the relevant API domain and scopes all calls to the specified client's sub-account.

## Config Location

The helper scripts resolve where your credentials live, in this order:

1. **`$GHL_CONFIG_DIR`** — explicit override; works anywhere
2. **`~/.ghl/`** — default for Claude Code / desktop (persistent home)
3. **a mounted `*/ghl-config` folder** — for Cowork, where the sandbox home is wiped between sessions, so config must live in a folder mounted from your computer

Inside that directory:
- `credentials.env` — API keys (permissions: 600)
- `clients.json` — client name-to-locationId mapping (permissions: 600)
- directory permissions: 700 (owner-only)

## Security

- API tokens are never displayed, logged, or included in conversation output
- All credential files use restrictive Unix permissions (700 directory, 600 files)
- Every API call requires specifying a client — no accidental cross-client access
- Write operations (create, update, delete) require confirmation before executing
- Tokens are referenced by variable name — values never enter Claude's context

## Need Help?

If you want help extending this plugin for your agency's specific workflows, or building custom AI automations on top of GHL, check out [abidingagency.com](https://abidingagency.com) — Chris does audits and builds for agencies running on HighLevel + AI.
