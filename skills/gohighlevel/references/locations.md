# Sub-Accounts (Locations) API Reference

In GHL, "Locations" are sub-accounts — each client gets their own location.

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/locations/search` | List all sub-accounts (agency key) |
| GET | `/locations/{locationId}` | Get sub-account details |
| POST | `/locations` | Create sub-account (Agency Pro) |
| PUT | `/locations/{locationId}` | Update sub-account |
| DELETE | `/locations/{locationId}` | Delete sub-account |

## List All Sub-Accounts

```
GET /locations/search
```

Requires agency-level API key (no `--token` needed). Returns all sub-accounts under the agency.

**Response:**
```json
{
  "locations": [
    {
      "id": "location-id",
      "name": "Acme Corp",
      "email": "acme@example.com",
      "phone": "+1234567890",
      "address": "123 Main St",
      "city": "Austin",
      "state": "TX",
      "postalCode": "78701",
      "country": "US"
    }
  ]
}
```

## Get Sub-Account Details

```
GET /locations/{locationId}
```

Returns full details including settings for a specific sub-account.

## Create Sub-Account

```
POST /locations
```
```json
{
  "name": "New Client Name",
  "email": "client@example.com",
  "phone": "+1234567890",
  "address": "456 Oak Ave",
  "city": "Dallas",
  "state": "TX",
  "postalCode": "75201",
  "country": "US"
}
```

**Note:** Creating sub-accounts via API requires an **Agency Pro plan**.

## Key Concepts

- Every sub-account has a unique `locationId`
- The `locationId` is what scopes all other API calls (contacts, tags, etc.) to that client
- Use the `discover` command in `ghl-client.sh` to pull all your sub-accounts and their IDs
- Store locationIds in `~/.ghl/clients.json` for easy reference
