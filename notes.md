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
| GitHub MCP | YES (npx) | PENDING — need GitHub PAT | NO |
| Suno MCP | YES (pip) | PENDING — need Suno API key | NO |
| PixelLab MCP | NOT YET | PENDING — need PixelLab API key | NO |
| Godot MCP Pro | NOT YET — purchase required ($5 itch.io) | N/A | NO |
| MCP Audio Tweaker | NOT YET | N/A | NO |

## Pending Manual Steps
1. [ ] Purchase Godot MCP Pro — itch.io, search "Godot MCP Pro" by youichi-uda ($5)
2. [ ] Get PixelLab API key — pixellab.ai → sign up → API settings
3. [ ] Get Suno API credentials — suno.ai → account → API access
4. [ ] Get GitHub Personal Access Token — github.com → Settings → Developer settings → PAT
5. [ ] Install Godot Tiled Importer plugin — after Godot project first open
6. [ ] Install MCP Audio Tweaker — npm install after Godot MCP Pro setup

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
