# GHL Plugin — Setup Instructions

## LinkedIn DM version (copy/paste below the line)

---

Hey! Here's how to get the GoHighLevel plugin working with Claude. Takes about 5 minutes.

**What you need:**
— Claude Pro/Team/Enterprise plan (either Cowork or Claude Code)
— Admin access to your GHL sub-account (full agency account is optional)
— Your sub-account's Location ID (Settings > Business Profile)

**Pick your install method:**

OPTION A — Claude Code (terminal)
If you use Claude Code, run these two commands:

/plugin marketplace add ancreon/gohighlevel-plugin
/plugin install gohighlevel@gohighlevel-plugin

This pulls from GitHub, so you'll get updates automatically when I push improvements.

OPTION B — Claude Cowork (desktop app)
I'll send you the .plugin file. Save it, then open Cowork and start a new session. Tell Claude:

"Install the GoHighLevel plugin"

Drag and drop the .plugin file into the chat, or use the attachment button to upload it. Claude will walk you through the rest.

**Next: Get your API token**

In your GHL sub-account, go to:
Settings > Integrations > Private Integrations > Create

Name it "Claude" or "Cowork", enable the scopes you want (contacts, calendars, tags, etc.), and save. Copy the token.

**Cowork only: connect a folder first**

Cowork runs in a sandbox that resets between sessions, so your credentials need to live in a folder on your own computer. Before running setup, connect any folder to the session (the folder picker in Cowork). Setup will store your config in a `ghl-config` subfolder there so it persists. (Claude Code users can skip this — it just uses `~/.ghl`.)

**Run setup**

Type /ghl-setup — it'll ask where to store config, then your token and Location ID. That's it, you're done.

**Try it out:**
— "Show me all tags"
— "List my contacts"
— "What calendars do I have?"
— "List workflows"

**Quick notes:**
— You do NOT need a full agency account. A single sub-account works great.
— If you DO have an agency account with multiple sub-accounts, the setup lets you add multiple clients with separate tokens for each.
— Your API token stays on your machine — it's never shown in chat or sent to Claude.
— Claude Code users get automatic updates from the repo. Cowork users would need a new .plugin file for updates.

Let me know if you hit any snags!

---
