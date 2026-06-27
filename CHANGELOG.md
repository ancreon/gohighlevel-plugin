# Changelog

All notable changes to the GoHighLevel plugin are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-06-27

Portable config resolution and export hardening. The plugin now works across
Claude Code and Cowork without hardcoding `~/.ghl`, and ships free of any
real client data.

### Added
- `scripts/lib-ghl-config.sh` — a single shared resolver for the config
  directory, sourced by both helper scripts so reads and writes can never
  disagree on location.
- Config-directory resolution order: `$GHL_CONFIG_DIR` (explicit override) →
  `~/.ghl` (Claude Code / desktop) → a mounted `*/ghl-config` or `*/.ghl`
  folder (Cowork, where the sandbox home is wiped between sessions).
- Cowork persistence guidance in the setup instructions (config must live in a
  connected folder to survive between sessions).

### Changed
- `ghl-api.sh` and `ghl-client.sh` now resolve config via the shared lib
  instead of hardcoding `~/.ghl`.
- `/ghl-setup` is environment-aware: it chooses a durable config location
  (`~/.ghl` for Claude Code, a mounted `ghl-config` folder for Cowork) instead
  of assuming `~/.ghl`.
- `SKILL.md` and `README.md` document the resolution order and the Cowork
  caveat; the not-found error message now explains all three tiers.
- Illustrative examples genericized to `acme` / `GHL_TOKEN_ACME`; removed real
  client names from all committed files.

### Fixed
- An explicit `GHL_CONFIG_DIR` is now honored unconditionally — previously it
  was ignored when the directory did not yet contain config, silently falling
  through to auto-discovered config.
- `ghl-client.sh add` now creates its target directory (`700`) and config file
  (`600`) when none exists, instead of failing on a fresh setup.

## [0.1.0]

Initial release — manage GoHighLevel agency sub-accounts via API v2 with
per-client isolation: tags, custom fields/values, calendars, scheduling,
products, contacts, and read/trigger-only workflows. Two-tier token model
(agency key + per-sub-account tokens) with `clients.json` mapping.

[0.2.0]: https://github.com/ancreon/gohighlevel-plugin/releases/tag/v0.2.0
[0.1.0]: https://github.com/ancreon/gohighlevel-plugin/releases/tag/v0.1.0
