cd /home/ls/gamedev-feudal && gh pr create --title "Add godot-gdscript skill for Godot 4.6 development" --body '## What this PR adds

This PR adds the godot-gdscript Hermes Agent skill located in `.claude/skills/godot-gdscript/`.

### Contents

- **SKILL.md**: Comprehensive guide for Godot 4.6 GDScript and scene authoring
  - TSCN/TRES file format requirements (format=3, load_steps, ExtResource refs)
  - GDScript strict rules (type hints, return types, script section order)
  - Godot 4 signal syntax only (no Godot 3 patterns)
  - Node parenting rules
  - Common patterns and best practices

- **validate_godot.py**: Validation script that enforces all skill rules
  - Checks TSCN/TRES files for proper format
  - Checks GDScript for typed vars, return types, Godot 4 syntax

### Usage

Load this skill with `skill_view(godot-gdscript)` when working on Godot projects.'
