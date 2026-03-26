# Calendars & Scheduling API Reference

## Calendar Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/calendars?locationId={id}` | List calendars |
| POST | `/calendars` | Create calendar |
| GET | `/calendars/{calendarId}` | Get calendar details |
| PUT | `/calendars/{calendarId}` | Update calendar |

## Appointment Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/calendars/{calendarId}/appointments` | List appointments |
| POST | `/calendars/{calendarId}/appointments` | Create appointment |
| GET | `/calendars/{calendarId}/appointments/{id}` | Get appointment |
| PUT | `/calendars/{calendarId}/appointments/{id}` | Update appointment |
| DELETE | `/calendars/{calendarId}/appointments/{id}` | Delete appointment |

## List Calendars

```
GET /calendars?locationId={locationId}
```

**Response:**
```json
{
  "calendars": [
    {
      "id": "calendar-id",
      "name": "Discovery Call",
      "locationId": "loc-id",
      "description": "30-minute initial consultation"
    }
  ]
}
```

## Create Calendar

```
POST /calendars
```
```json
{
  "locationId": "location-id",
  "name": "Discovery Call",
  "description": "30-minute initial consultation"
}
```

## Create Appointment

```
POST /calendars/{calendarId}/appointments
```
```json
{
  "title": "Discovery Call with Jane",
  "startTime": "2026-04-01T10:00:00-05:00",
  "endTime": "2026-04-01T10:30:00-05:00",
  "contactId": "contact-id",
  "calendarId": "calendar-id"
}
```

**Key fields:**
- `title` (required)
- `startTime` / `endTime` (ISO 8601 with timezone)
- `contactId` (optional — links to a GHL contact)
- `calendarId` (required)

## Notes

- Calendars are scoped to a sub-account via `locationId`
- Appointment times should include timezone offsets
- Calendars in GHL also control booking widget availability
