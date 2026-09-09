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

## The tag object

A tag carries more than a name. Verified live 2026-09-09:

```json
{
  "id": "tag-id",
  "name": "membership - status - flight school - active",
  "locationId": "loc-id",
  "categoryId": "6aa1a380738bab2ea003f6f2",
  "description": "Contact is currently enrolled in Flight School.",
  "color": "#027A48"
}
```

- **`description`** — free text. Writable via PUT. Empty on every tag by default.
- **`color`** — hex string, e.g. `#027A48`. Writable via PUT.
- **`categoryId`** — read-only here; assigned in the GHL UI. Preserved across a
  PUT as long as you do not send the field.

## Update a Tag

```
PUT /locations/{locationId}/tags/{tagId}
```
```json
{
  "name": "existing tag name",
  "description": "What this tag means and whether it is safe to remove.",
  "color": "#3538CD"
}
```

**`name` is required on every PUT.** Omitting it will fail or rename. Always send
the tag's current name back unchanged unless you intend a rename.

Sending only `name` + `description` + `color` preserves `categoryId`. Verified.

### Gotcha: `color` is not validated

The API accepts **any string** in `color` and returns `200`. Sending the literal
string `"red"` stores `"color": "red"`, which renders as nothing in the UI. There
is no error and no warning. A typo'd hex persists silently.

**Always set colors by script, never by hand**, and re-read the tag list to
verify what actually landed.

## Tag categories — NOT available via API

The route exists but is not wired into GHL's IAM:

```
GET /locations/{locationId}/tags/categories
401  {"statusCode":401,
      "message":"This route is not yet supported by the IAM Service.
                 Please update your IAM config."}
```

Ruled out as a scope problem — verified 2026-09-09 with **both** an agency key
and a sub-account PIT, on **both GET and POST**, while a control call to
`/tags` returned 200 in the same session. No token can open this route.

**Category names and descriptions must be edited in the GHL UI.** Category
membership can still be *read* from each tag's `categoryId`; group by that field
to reconstruct the category structure.

## List Tags

```
GET /locations/{locationId}/tags
```

Returns `{"tags": [...]}`. Not paginated in practice for typical tag counts.

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

Pass tag names as strings — GHL resolves them. Tags that don't exist yet get
created automatically. **This is a common source of tag sprawl** — a typo in a
workflow silently creates a new tag.

## Remove Tag from Contact

```
DELETE /contacts/{contactId}/tags/{tagId}
```

Requires the tag ID (not name). List tags first to get the ID.

## Bulk edits

For any pass over more than a handful of tags:

1. `GET` the full list and save it to a file — that snapshot is your rollback.
2. Build a name-keyed map of intended values.
3. **Abort if the map and the live list disagree** — a tag added by someone else
   mid-run means your map is stale.
4. Write with ~0.15s between calls (limit is 100 req / 10s).
5. Re-`GET` and diff against intent. Check `name` and `categoryId` for drift,
   not just the fields you meant to change.
