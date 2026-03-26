# Tags API Reference

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/tags?locationId={id}` | List all tags |
| POST | `/tags` | Create a tag |
| GET | `/tags/{tagId}` | Get single tag |
| PUT | `/tags/{tagId}` | Update a tag |
| DELETE | `/tags/{tagId}` | Delete a tag |
| POST | `/contacts/{contactId}/tags` | Add tags to contact |
| DELETE | `/contacts/{contactId}/tags/{tagId}` | Remove tag from contact |

## List Tags

```
GET /tags?locationId={locationId}
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
POST /tags
```
```json
{ "locationId": "location-id", "name": "New Tag Name" }
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
