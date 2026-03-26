# Custom Fields & Custom Values API Reference

## Custom Fields (Schema)

Define what fields exist in a sub-account.

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/custom-fields?locationId={id}` | List custom fields |
| POST | `/custom-fields` | Create custom field |
| GET | `/custom-fields/{fieldId}` | Get single field |
| PUT | `/custom-fields/{fieldId}` | Update field |
| DELETE | `/custom-fields/{fieldId}` | Delete field |

## List Custom Fields

```
GET /custom-fields?locationId={locationId}
```

**Response:**
```json
{
  "customFields": [
    {
      "id": "field-id",
      "name": "Lead Source",
      "fieldType": "selection",
      "options": ["Google Ads", "Referral", "Website"],
      "locationId": "loc-id"
    }
  ]
}
```

## Create Custom Field

```
POST /custom-fields
```
```json
{
  "locationId": "location-id",
  "name": "Annual Revenue",
  "fieldType": "number"
}
```

**Supported Field Types:** `text`, `number`, `selection`, `date`, `textarea`, `checkbox`, `signature`

### Selection Field with Options

```json
{
  "locationId": "location-id",
  "name": "Industry",
  "fieldType": "selection",
  "options": ["Technology", "Healthcare", "Finance", "Education", "Other"]
}
```

## Setting Custom Values on Contacts

Pass custom values in the `customFields` array when creating/updating contacts:

```json
{
  "locationId": "location-id",
  "firstName": "Jane",
  "customFields": [
    { "id": "field-id-for-lead-source", "value": "Referral" },
    { "id": "field-id-for-revenue", "value": "500000" }
  ]
}
```

You need the field ID (from listing custom fields) to set values.

## Typical Workflow

1. Create custom field definitions for the sub-account
2. Note the returned field IDs
3. Use those IDs when creating/updating contacts
