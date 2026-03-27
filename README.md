# GoHighLevel Plugin

Built by [Chris Barber](https://github.com/ancreon) at [Abiding Agency](https://abidingagency.com)

Manage your GoHighLevel agency sub-accounts via API from any Claude session. Supports automations, tags, custom fields/values, calendars, scheduling, products, and contacts — all with per-client isolation.

## Components

| Type | Name | Purpose |
|------|------|---------|
| Skill | `gohighlevel` | API knowledge and usage patterns for all GHL endpoints |
| Command | `/ghl-setup` | Interactive first-time credential and client setup |
| Command | `/ghl-clients` | List, add, or remove client configurations |

## Setup

### Required

1. A GoHighLevel Agency account with API access
2. An Agency API key (Private Integration token)

### First-Time Setup

Run `/ghl-setup` in any Claude session to walk through:
1. Creating the secure `~/.ghl/` directory
2. Storing your API key in `~/.ghl/credentials.env`
3. Discovering your sub-accounts
4. Configuring your client list in `~/.ghl/clients.json`

### Environment

Credentials are stored at:
- `~/.ghl/credentials.env` — Agency API key (permissions: 600)
- `~/.ghl/clients.json` — Client name-to-locationId mapping (permissions: 600)
- `~/.ghl/` directory permissions: 700 (owner-only)

## Usage

Once set up, just mention GHL in conversation:
- "Show me all tags for acme"
- "Create a Discovery Call calendar for client-x"
- "List custom fields for client-y"
- "Add a new product for client-z"

The skill automatically loads reference docs for the relevant API domain and scopes all calls to the specified client's sub-account.

## Security

- API key is never displayed, logged, or included in conversation output
- All credential files use restrictive Unix permissions
- Every API call requires specifying a client — no accidental cross-client access
- Write operations (create, update, delete) require confirmation before executing
