# Godot Plugin Skills for Feudal Game Development

This directory contains Agent Skills (following the [agentskills.io](https://agentskills.io/specification) format) derived from the deep research report on Godot plugins suitable for feudal‑style game development.

Each skill provides detailed, self‑contained knowledge about a specific plugin, asset library, or system, enabling AI agents to work effectively with these tools within the Feudal Game project.

## Skill Index

| Skill | Description | License |
|-------|-------------|---------|
| [3d‑controls‑toolkit](3d-controls-toolkit/SKILL.md) | 3D camera/controller plugin with four control schemes (first‑person, third‑person, side‑scrolling, top‑down) | Unknown |
| [humanizer](humanizer/SKILL.md) | 3D character creation system based on MakeHuman, with procedural generation, rigging, and animation retargeting | Likely CC0 (assets) |
| [hterrain](hterrain/SKILL.md) | Heightmap‑based terrain system with sculpting, texture painting, LOD, and detail layers | MIT (assumed) |
| [ambientcg‑polyhaven](ambientcg-polyhaven/SKILL.md) | CC0‑licensed PBR material, HDRI, and 3D‑model libraries | CC0 |
| [navigation‑region3d](navigation-region3d/SKILL.md) | Godot’s built‑in 3D navigation system (navmesh baking, pathfinding, obstacle avoidance) | Built‑in (MIT) |
| [godot‑steering‑ai](godot-steering-ai/SKILL.md) | Steering‑behavior framework (seek, flee, flock, etc.) – **note:** Godot 3.x, outdated | MIT (assumed) |
| [rts‑camera‑selection](rts-camera-selection/SKILL.md) | RTS‑style camera controllers and unit‑selection patterns | MIT (assumed) |
| [beehave‑behavior‑trees](beehave-behavior-trees/SKILL.md) | Node‑based behavior‑tree implementation for AI with blackboard and debugging tools | MIT (assumed) |

## Usage

These skills are designed for consumption by AI agents (e.g., Hermes, Claude Code) that support the Agent Skills protocol. When loaded, a skill provides:

- **Frontmatter metadata** (name, description, license, compatibility, tags)
- **Detailed content** covering “What It Is”, “How It Works”, installation, configuration, usage examples, and known gaps
- **Structured knowledge** that can be queried programmatically

To use a skill manually, simply read the corresponding `SKILL.md` file. For integration with an AI agent, refer to the agent’s documentation for loading skills from a local directory.

### Integration with Hermes Agent

These skills have also been installed in the active Hermes profile at:

```
~/.hermes/profiles/gamedev/skills/gamedev/
```

When working within the Feudal Game project, Hermes Agent will automatically load the relevant skills when they match the task context. You can view a skill’s content with:

```bash
skill_view 3d-controls-toolkit
```

## Source

All skills were extracted from the research report:

> [`../research/plugin‑deep‑research.md`](../research/plugin-deep-research.md)

The conversion preserved the original research content while adding the required YAML frontmatter and normalizing formatting.

## Adding New Skills

1. Create a new directory under `docs/skills/` with a kebab‑case name (e.g., `new‑plugin‑skill`).
2. Inside the directory, create a `SKILL.md` file with the following structure:

   ```markdown
   ---
   name: skill-name
   description: A concise description of what this skill does and when to use it.
   license: LicenseName or “Unknown”
   compatibility: Godot 4.x, Feudal Game project
   metadata:
     repository: "https://..."
     maintainer: "Author Name"
     version: "1.0.0"
   tags:
     - godot
     - plugin
     - feudal-game
   ---

   # Title

   Content (markdown)…
   ```

3. Ensure the description does not exceed 1024 characters and the name follows the agentskills.io naming rules (lowercase, hyphens, ≤64 chars).

4. Update this `README.md` with the new skill entry.

## Regeneration

If the source research file (`../research/plugin‑deep‑research.md`) is updated, you can regenerate all skills with the provided script:

```bash
cd /home/ls/gamedev-feudal
python3 docs/skills/generate_skills.py [--clean] [--dry-run]
```

- `--clean`: remove existing skill directories before generating
- `--dry-run`: show what would be generated without writing files

The script parses the research file, extracts each plugin section, and produces fresh SKILL.md files with proper frontmatter. It also regenerates the research‑gaps skill.

**Note:** Manual edits to individual SKILL.md files are the source of truth. The regeneration script is kept for reference but may not reflect the latest skill content. To preserve manual changes, avoid running the script or ensure you have a backup.

## License Notes

- Where a license is explicitly stated in the source research, it is included in the skill’s `license` field.
- For plugins where the license is unknown or assumed, the field reflects that uncertainty.
- CC0‑licensed assets (AmbientCG, Polyhaven) are completely free for commercial use without attribution.

## Integration with Feudal Game Project

These skills are intended to guide development decisions and implementation of plugin‑based features in the Feudal Game. When planning a vertical slice or new mechanic, consult the relevant skill to understand the plugin’s capabilities, installation steps, and known limitations.

---


*Last updated: 2026‑04‑16*