# Tags API Reference

**Requires sub-account token** — use `--token` flag with the helper script.

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/locations/{locationId}/tags` | List all tags |
| POST | `/locations/{locationId}/tags` | Create a tag |
| GET | `/locations/{locationId}/tags/{tagId}` | Get single tag |
| PUT | `/locations/{locationId}/tags/{tagId}` | Update a tag |
| DELETE | `/locations/{locationId}/tags/{tagId}` | Delete a tag |
| POST | `/contacts/{contactId}/tags` | Add tags to contact |
| DELETE | `/contacts/{contactId}/tags/{tagId}` | Remove tag from contact |

## List Tags

```
GET /locations/{locationId}/tags
```

**Response:**
```json
{
  "tags": [
    { "id": "tag-id", "name": "VIP", "locationId": "loc-id" },
    { "id": "tag-id-2", "name": "Active Client", "locationId": "loc-id" }
  ]
}
```

## Create Tag

```
POST /locations/{locationId}/tags
```
```json
{ "name": "New Tag Name" }
```

Tag names must be unique within a sub-account.

## Add Tags to Contact

```
POST /contacts/{contactId}/tags
```
```json
{ "tags": ["VIP", "Priority"] }
```

Pass tag names as strings — GHL resolves them. Tags that don't exist yet get created automatically.

## Remove Tag from Contact

```
DELETE /contacts/{contactId}/tags/{tagId}
```

Requires the tag ID (not name). List tags first to get the ID.
