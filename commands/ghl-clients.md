---
description: List, add, or remove GHL client configs
allowed-tools: Bash, Read
argument-hint: [list|add|remove] [client-name]
---

Manage the GoHighLevel client configuration.

If no arguments provided, list all configured clients:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-client.sh list
```

If arguments provided, pass them through:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/gohighlevel/scripts/ghl-client.sh $ARGUMENTS
```

Show the results in a clean, readable format. Never display the API key or credentials file contents.
