---
name: godot-mcp
description: Guide for using the Godot MCP (Model Context Protocol) server to interact with Godot 4.x projects programmatically via Hermes Agent. Covers setup, available tools, workflows, and troubleshooting.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [godot, mcp, gamedev, automation, cli]
---

# Godot MCP Server — Skill Guide

## What is godot-mcp?

`godot-mcp` is a Model Context Protocol server that exposes Godot 4.x engine operations as callable tools. It allows AI agents (like Hermes) to create scenes, add nodes, run projects, and inspect debug output without manual GUI interaction.

## Prerequisites

- Godot 4.x installed and available in `PATH` (or via `GODOT_PATH` env var)
- `godot-mcp` npm package installed globally:
  ```bash
  npm install -g @coding-solo/godot-mcp
  ```
- Hermes Agent with MCP support

## Starting the Server

### Standalone (for testing)
```bash
godot-mcp serve
```
The server runs on **stdio** (not HTTP). It spawns Godot processes internally to execute operations.

### Hermes Integration
Add to `~/.hermes/config.yaml` under `mcp_servers`:
```yaml
mcp_servers:
  godot:
    url: http://localhost:39736/mcp
```

Then register the server with Hermes:
```bash
hermes mcp add godot --command godot-mcp --args serve
```

Verify:
```bash
hermes mcp list
hermes mcp test godot
```

## Available Tools

| Tool | Description |
|------|-------------|
| `launch_editor` | Open the Godot editor for a specific project path |
| `run_project` | Run a Godot project in debug mode |
| `get_debug_output` | Fetch console logs, errors, and stack traces from the running project |
| `get_godot_version` | Return installed Godot version string |
| `list_projects` | Discover Godot projects in a directory (recursive optional) |
| `get_project_info` | Return metadata: scene count, script count, asset count |
| `create_scene` | Create a new `.tscn` file with a specified root node type |
| `add_node` | Add a node to an existing scene file |
| `save_scene` | Persist scene changes to disk |
| `load_sprite` | Assign a texture to a `Sprite2D` node |
| `export_mesh_library` | Export a scene as a `MeshLibrary` resource |
| `update_project_uids` | Regenerate UID references across the project (Godot 4.4+) |
| `get_uid` | Retrieve the UID for a specific file |

## Standard Workflow

1. **Prep** — Call `get_project_info` to verify the target project context.
2. **Execute** — Use `create_scene`, `add_node`, `load_sprite`, or file edits to modify the project.
3. **Validate** — Call `run_project` to start the project, then immediately call `get_debug_output` to inspect logs.
4. **Headless Check** — Run `godot --path <project> --headless --quit` to verify no load errors.
5. **Iterate** — If errors appear, fix them and re-run.

## Critical Limitations

### Editor Lock Conflict
**godot-mcp tools will fail if a Godot editor instance is already open for the same project.**

Symptoms:
- `run_project` appears to succeed but `get_debug_output` returns "No active Godot process"
- Debug output is empty despite the project running
- MCP tools hang or return stale data

Workarounds:
- **Close the Godot editor** before using MCP tools on that project.
- For validation while the editor is open, use the Godot CLI directly:
  ```bash
  godot --path ./src/my-project --headless --quit
  ```
- Use `launch_editor` via MCP instead of manually opening Godot, so the MCP server owns the process.

### Environment Variables
- `GODOT_PATH` — Override path to the Godot binary
- `DEBUG` — Enable verbose logging from the MCP server

## When to Use godot-mcp vs CLI

| Task | Preferred Method |
|------|----------------|
| Create/edit scenes structurally | `mcp_godot_create_scene`, `mcp_godot_add_node` |
| Run project and get live logs | `mcp_godot_run_project` + `mcp_godot_get_debug_output` |
| Quick headless validation | `godot --path <project> --headless --quit` |
| Bulk file operations, text edits | Terminal / `patch` / `write_file` |
| Open editor for visual inspection | `mcp_godot_launch_editor` |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `hermes mcp test godot` fails | Ensure `godot-mcp serve` is running; check `hermes mcp list` |
| `get_debug_output` returns nothing | Project may have crashed or editor lock is active; check with headless CLI |
| Scenes created but not visible | Call `save_scene` after modifications; verify file paths |
| UID warnings after copying scenes | Run `update_project_uids` on the project |
| Import errors for new assets | Run Godot headless once to trigger reimport: `godot --path <project> --editor --quit --headless` |

## Example: Creating a Scene via MCP

```python
# Using Hermes MCP tools
mcp_godot_create_scene(
    projectPath="/home/user/projects/my-game",
    scenePath="scenes/Player.tscn",
    rootNodeType="CharacterBody2D"
)

mcp_godot_add_node(
    projectPath="/home/user/projects/my-game",
    scenePath="scenes/Player.tscn",
    parentNodePath="root",
    nodeType="Sprite2D",
    nodeName="Sprite2D"
)

mcp_godot_save_scene(
    projectPath="/home/user/projects/my-game",
    scenePath="scenes/Player.tscn"
)
```

## Related Skills

- `godot-gdscript` — Validation rules for `.gd`, `.tscn`, `.tres` files
- `godot-slice-modification` — Copying and modifying vertical slices
- `godot-mcp-workflow` — Scene creation and validation workflow
