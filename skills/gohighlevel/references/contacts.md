# Contacts API Reference

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/contacts/search?locationId={id}` | Search/list contacts |
| GET | `/contacts/{contactId}` | Get single contact |
| POST | `/contacts` | Create contact |
| PUT | `/contacts/{contactId}` | Update contact |
| DELETE | `/contacts/{contactId}` | Delete contact |
| POST | `/contacts/{contactId}/tags` | Add tags to contact |
| DELETE | `/contacts/{contactId}/tags/{tagId}` | Remove tag from contact |

## Search Contacts

```
GET /contacts/search?locationId={locationId}&query={searchTerm}&limit=20
```

**Query Parameters:**
- `locationId` (required) — sub-account ID
- `query` — search term (name, email, phone)
- `limit` — results per page (default 20, max 100)
- `startAfterId` — cursor for pagination
- `tags` — filter by tag names (comma-separated)

**Response:**
```json
{
  "contacts": [
    {
      "id": "contact-id",
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "tags": ["VIP", "Active"],
      "customFields": [...]
    }
  ],
  "meta": { "total": 150, "startAfterId": "cursor-value" }
}
```

## Create Contact

```
POST /contacts
```
```json
{
  "locationId": "location-id",
  "firstName": "Jane",
  "lastName": "Smith",
  "email": "jane@example.com",
  "phone": "+1234567890",
  "tags": ["New Lead"],
  "customFields": [
    { "id": "custom-field-id", "value": "field value" }
  ]
}
```

## Update Contact

```
PUT /contacts/{contactId}
```
Same fields as create — only include fields to update.

## Pagination

Cursor-based: use `startAfterId` from response meta for next page. Repeat until no more results returned.
