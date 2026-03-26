# Workflows (Automations) API Reference

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/workflows?locationId={id}` | List workflows |
| GET | `/workflows/{workflowId}` | Get workflow details |

## List Workflows

```
GET /workflows?locationId={locationId}
```

**Response:**
```json
{
  "workflows": [
    {
      "id": "workflow-id",
      "name": "New Lead Follow-Up",
      "status": "active",
      "locationId": "loc-id"
    }
  ]
}
```

## What You Can Do via API

- List all workflows for a sub-account
- View workflow details and status
- Trigger a workflow for a specific contact
- Enroll contacts into workflows

## What's Better Done in the GHL UI

The GHL API v2 provides read access and triggering for workflows, but building complex workflow logic (triggers, conditions, branching) is still best done in the GHL visual builder.

**Practical flow for "setting up automations":**
1. Use the API to audit what workflows already exist
2. Help plan the workflow structure and logic
3. Build the workflow in GHL's UI
4. Use the API to verify it's active and bulk-enroll contacts

## Enrolling Contacts into Workflows

```
POST /contacts/{contactId}/workflow/{workflowId}
```

Useful for bulk operations like "enroll all contacts tagged X into workflow Y."
