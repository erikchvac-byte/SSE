# SSE Project Notes

## Current State
**Last Updated**: 2026-04-16
**Phase**: Project scaffolded — awaiting MCP credential setup

## Environment
- OS: Windows 11
- Shell: Git Bash / PowerShell
- Godot: 4.6.2 stable (C:\Program Files\Godot\)
- FFmpeg: 8.1 (via winget, in PATH)
- Node.js: v24.13.0
- Python: 3.13.5
- Git LFS: 3.7.0
- mcp-suno: 2026.4.8.4 (pip installed)

## MCP Status
| MCP | Installed | Credentials | Ready |
|---|---|---|---|
| Filesystem MCP | YES (npx) | N/A | YES |
| GitHub MCP | YES (npx) | YES — PAT configured | YES ⚠️ regenerate PAT |
| Suno MCP | YES (pip) | PENDING — need Suno API key | NO |
| PixelLab MCP | YES (npx) | YES — key configured | YES |
| Godot MCP Pro | YES — v1.7.0 built | N/A | YES (needs editor open) |
| MCP Audio Tweaker | NOT YET | N/A | NO — FFmpeg is fallback |

## Godot MCP Pro
- Location: C:/Users/erikc/Downloads/godot-mcp-pro-v1.7.0/
- Server: C:/Users/erikc/Downloads/godot-mcp-pro-v1.7.0/server/build/index.js
- Plugin: copied to godot_project/addons/godot_mcp/
- Port: 6505
- REQUIRED: Open Godot editor and enable plugin before any MCP calls
  - Project → Project Settings → Plugins → Godot MCP Pro → Enable

## Pending Manual Steps
1. [ ] Open Godot, enable Godot MCP Pro plugin (Project → Project Settings → Plugins)
2. [ ] Get Suno API key — suno.ai → account → API access
3. [ ] Install Godot Tiled Importer plugin — after Godot project first open
4. [ ] Install MCP Audio Tweaker — optional, FFmpeg covers this
5. [!] Regenerate GitHub PAT — was exposed in conversation history

## Credentials Storage
- Store all API keys in `.env` (gitignored)
- Never commit credentials to GitHub

## Git
- Repo: NOT YET INITIALIZED — pending GitHub PAT
- LFS patterns configured in .gitattributes
- Remote: TBD

## Godot Project
- Path: C:/Users/erikc/Dev/SSE/godot_project/
- Version: 4.6.2
- Status: project.godot created, not yet opened in editor

## Known Issues
- MCP Audio Tweaker is pre-release (0 official releases) — FFmpeg is the authoritative fallback
- Godot MCP Pro requires editor to be open before any MCP calls
