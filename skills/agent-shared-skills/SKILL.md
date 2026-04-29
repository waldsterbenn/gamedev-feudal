---
name: agent-shared-skills
category: gamedev
description: Share a common project skills/ directory across multiple AI agent context folders (.claude/, .gemini/, etc.) using symlinks, while avoiding stale copy pitfalls.
---

# Agent Shared Skills via Symlinks

Use this pattern when a project has a shared `skills/` directory that multiple AI agents (Claude Code, Gemini, etc.) should all see, each through their own agent-specific context folder.

## Problem

AI agent tools like Claude Code read skills from `.claude/skills/`. If you manually copy skills there, they become stale when the root `skills/` directory is updated. You want a single source of truth.

## Solution

Symlink the agent's skills subdirectory to the project's shared skills directory.

## Steps

### 1. Locate the shared skills directory
This is typically at the project root:
```
project-root/skills/
```

### 2. Check if the agent already has a skills subfolder
```bash
ls -la .claude/skills
```

**CRITICAL**: Never blindly create a symlink. The agent folder may already contain a `skills/` directory with files.

### 3. Compare contents if the directory exists
```bash
diff -r .claude/skills/ skills/
```

If the agent's copy is outdated (missing sections, older timestamps), the root `skills/` is the authoritative version.

### 4. Replace the directory with a symlink
```bash
cd .claude
rm -rf skills          # remove the stale copy
ln -s ../skills skills # create symlink to root skills/
```

### 5. Verify
```bash
ls -la .claude/skills
diff .claude/skills/<some-skill>/SKILL.md skills/<some-skill>/SKILL.md
```

## Why This Works

- The agent traverses `.claude/skills/` transparently through the symlink
- Updates to `skills/` are immediately visible to the agent
- No duplication, no stale copies

## Pitfalls

1. **Blind symlink over existing directory**: `ln -s` creates the symlink *inside* the existing directory if it already exists. Always `rm -rf` the old directory first (after diffing to confirm it's safe).

2. **Relative path mistakes**: Use `../skills` (relative to `.claude/`), not `./skills` or absolute paths that break if the project is moved.

3. **Agent-specific files mixed in**: If the agent's `skills/` contains files NOT in the root `skills/` (e.g., agent-specific configs), move those out first or keep them in a separate subfolder.

4. **Windows incompatibility**: Symlinks on Windows require Developer Mode or admin privileges. This pattern assumes Unix-like environments (Linux, macOS, WSL).

5. **Git staging symlinks with pathspecs**: Running `git add -u .claude/skills/` fails with `fatal: pathspec '.claude/skills/' is beyond a symbolic link`. Use bare `git add -u` (stages all tracked changes) or `git add .claude/skills` (adds the symlink itself as a new file) instead.

## When to Use

- `.claude/skills` should mirror `skills/`
- `.gemini/skills` should mirror `skills/`
- The agent's own persistent profile skills (e.g., `~/.hermes/profiles/<profile>/skills/gamedev/`) should share skills with the project without duplication

## Advanced: Agent Profile Skills (Bidirectional Symlinks)

The agent's own skill profile directory (where skills are loaded from during sessions) may already contain skills that overlap with the project. **Do not blindly symlink the entire profile directory** — use a hybrid approach:

### 1. Compare profile skills against project skills
```bash
ls ~/.hermes/profiles/<profile>/skills/gamedev/
ls /path/to/project/skills/
```

### 2. For each overlapping skill, diff to find the better version
```bash
for skill in skill-a skill-b skill-c; do
    diff -r ~/.hermes/profiles/<profile>/skills/gamedev/"$skill" /path/to/project/skills/"$skill"
done
```

### 3. Apply the hybrid symlink strategy

| Situation | Action | Rationale |
|---|---|---|
| Skill exists in both, project version is newer/better | Replace profile copy with symlink **to** project | Project = source of truth |
| Skill exists only in project | Create symlink **from** project **into** profile | Agent can now discover and load it |
| Skill exists only in profile | Leave as real folder | Agent-specific skill, not project-related |

Example:
```bash
cd ~/.hermes/profiles/<profile>/skills/gamedev

# Project is source of truth for shared skills
for skill in godot-gdscript hterrain godot-mcp; do
    rm -rf "$skill"
    ln -s /path/to/project/skills/"$skill" "$skill"
done

# Pull project-only skills into my profile so I can use them
for skill in godot-steering-ai navigation-region3d; do
    ln -s /path/to/project/skills/"$skill" "$skill"
done
```

### 4. Verify
```bash
ls -la ~/.hermes/profiles/<profile>/skills/gamedev/
# Symlinks should point to project; unique skills should remain real folders
```

## Committing the Refactor

When committing symlink changes, be careful not to stage unrelated untracked files (e.g., `.hermes/`, conversation logs, slice `.gitignore`/`.gitattributes`). Stage only the relevant changes:

```bash
# Stage the new root skills/ directory and symlink files
git add skills/ .claude/skills .gemini/skills

# Stage deletions of old copies (use bare -u, not pathspecs)
git add -u

# Verify nothing unrelated was staged
git status

git commit -m "refactor: centralize skills in root dir; symlink for agent profiles

- Move docs/skills -> skills/ at project root (single source of truth)
- Replace .claude/skills/ and .gemini/skills/ with symlinks to ../skills
- Symlink project skills into Hermes profile (bidirectional hybrid)
- Ensures all agents always see latest skill versions"
```

- [ ] `ls -la .claude/skills` shows `skills -> ../skills`
- [ ] `diff` confirms files are identical between agent view and root
- [ ] No real directories named `skills` remain inside agent folders
- [ ] Agent profile skills show correct mix of symlinks (to project) and real folders (agent-unique)