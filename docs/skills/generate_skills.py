#!/usr/bin/env python3
"""
Skill Generator for Feudal Game Plugin Research

This script parses the plugin‑deep‑research.md file and generates/updates
Agent Skills in the docs/skills/ directory.

Usage:
    python3 generate_skills.py [--clean] [--dry-run]

Dependencies: Python 3.11+, standard library only.
"""

import argparse
import re
import shutil
from pathlib import Path
import sys

# Paths
PROJECT_ROOT = Path(__file__).parent.parent.parent
RESEARCH_FILE = PROJECT_ROOT / "docs" / "research" / "plugin-deep-research.md"
SKILLS_DIR = PROJECT_ROOT / "docs" / "skills"

# Plugin titles and corresponding skill names (in order of appearance in the report)
PLUGINS = [
    ("3D Controls Toolkit", "3d-controls-toolkit"),
    ("Humanizer", "humanizer"),
    ("KayKit Character Pack (Adventurers)", "kaykit-character-pack"),
    ("HTerrain (Heightmap Terrain Plugin)", "hterrain"),
    ("AmbientCG & Polyhaven", "ambientcg-polyhaven"),
    ("NavigationRegion3D & NavigationMesh (Built-in Godot)", "navigation-region3d"),
    ("Godot Steering AI Framework", "godot-steering-ai"),
    ("Godot RTS Camera & Selection", "rts-camera-selection"),
    ("Beehave (Behavior Trees)", "beehave-behavior-trees"),
]

def clean_content(text: str) -> str:
    """Remove common leading indentation from each line."""
    lines = text.split('\n')
    # Find minimum non‑zero indent
    min_indent = None
    for line in lines:
        if line.strip():
            indent = len(line) - len(line.lstrip())
            if min_indent is None or indent < min_indent:
                min_indent = indent
    if min_indent is None:
        min_indent = 0
    # Dedent
    cleaned = '\n'.join(line[min_indent:] for line in lines)
    return cleaned.strip()

def extract_metadata(text: str) -> dict:
    """Extract key‑value pairs like **Repository:** value."""
    metadata = {}
    patterns = {
        'repository': r'\*\*Repository:\*\*\s*(.+?)(?=\n|$)',
        'wiki': r'\*\*Wiki:\*\*\s*(.+?)(?=\n|$)',
        'maintainer': r'\*\*Maintainer:\*\*\s*(.+?)(?=\n|$)',
        'version': r'\*\*Version:\*\*\s*(.+?)(?=\n|$)',
        'license': r'\*\*License:\*\*\s*(.+?)(?=\n|$)',
        'source': r'\*\*Source:\*\*\s*(.+?)(?=\n|$)',
        'documentation': r'\*\*Documentation:\*\*\s*(.+?)(?=\n|$)',  
    }
    for key, pattern in patterns.items():
        match = re.search(pattern, text)
        if match:
            metadata[key] = match.group(1).strip()
    return metadata

def extract_description(text: str) -> str:
    """Extract the first paragraph after '### What It Is' or '### What They Are'."""
    desc_match = re.search(
        r'### What (It Is|They Are)\s*\n(.+?)(?=\n###|\n---|\n##|\n\*\*|\n#|\n$)',
        text, re.DOTALL
    )
    if desc_match:
        raw = desc_match.group(2).strip()
        # Take first sentence (up to first period) or first 150 chars
        first_sentence = raw.split('.')[0] + '.'
        if len(first_sentence) > 150:
            first_sentence = first_sentence[:147] + '...'
        return first_sentence
    return "Skill for using this plugin in Godot feudal game development."

def generate_skill(skill_name: str, title: str, content: str, metadata: dict) -> str:
    """Generate a complete SKILL.md file."""
    description = extract_description(content)
    # Build frontmatter
    frontmatter_lines = [
        "---",
        f"name: {skill_name}",
        f"description: {description}",
        f"license: {metadata.get('license', 'Unknown')}",
        "compatibility: Godot 4.x, Feudal Game project",
        "metadata:"
    ]
    for key, val in metadata.items():
        frontmatter_lines.append(f"  {key}: \"{val}\"")
    frontmatter_lines.append("tags:")
    frontmatter_lines.append("  - godot")
    frontmatter_lines.append("  - plugin")
    frontmatter_lines.append("  - feudal-game")
    frontmatter_lines.append("---")
    frontmatter = '\n'.join(frontmatter_lines)
    # Combine
    return f"{frontmatter}\n\n{content}\n"

def parse_research_file() -> tuple[list[tuple[str, str, str, dict]], str]:
    """
    Parse the research file and return:
    - list of (title, skill_name, content, metadata) for each plugin
    - content of the 'Research Gaps & Next Steps' section
    """
    if not RESEARCH_FILE.exists():
        raise FileNotFoundError(f"Research file not found: {RESEARCH_FILE}")
    
    text = RESEARCH_FILE.read_text()
    # Split by '---' separators (with optional surrounding whitespace)
    sections = re.split(r'\n\s*---\s*\n', text)
    
    # First section contains intro + plugin 1
    section0 = sections[0]
    plugin1_start = re.search(r'## 1\. 3D Controls Toolkit', section0).start()
    plugin1_content = section0[plugin1_start:]
    
    # Plugins 2–9 are in sections[1]–sections[8]
    plugin_contents = [plugin1_content] + sections[1:9]
    
    # Research gaps section
    gaps_section = sections[9] if len(sections) > 9 else ""
    
    result = []
    for (title, skill_name), raw_content in zip(PLUGINS, plugin_contents):
        content = clean_content(raw_content)
        metadata = extract_metadata(content)
        result.append((title, skill_name, content, metadata))
    
    return result, clean_content(gaps_section)

def main():
    parser = argparse.ArgumentParser(description="Generate Agent Skills from plugin research.")
    parser.add_argument("--clean", action="store_true",
                        help="Remove existing skill directories before generating.")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would be generated without writing files.")
    args = parser.parse_args()
    
    # Ensure skills directory exists
    SKILLS_DIR.mkdir(parents=True, exist_ok=True)
    
    # Parse research file
    try:
        plugins, gaps_content = parse_research_file()
    except Exception as e:
        print(f"Error parsing research file: {e}", file=sys.stderr)
        return 1
    
    print(f"Found {len(plugins)} plugins and research gaps section.")
    
    # Clean existing skill directories if requested
    if args.clean and not args.dry_run:
        for _, skill_name, _, _ in plugins:
            skill_dir = SKILLS_DIR / skill_name
            if skill_dir.exists():
                shutil.rmtree(skill_dir)
        gaps_dir = SKILLS_DIR / "feudal-game-plugin-research-gaps"
        if gaps_dir.exists():
            shutil.rmtree(gaps_dir)
        print("Cleaned existing skill directories.")
    
    # Generate plugin skills
    for title, skill_name, content, metadata in plugins:
        skill_dir = SKILLS_DIR / skill_name
        if args.dry_run:
            print(f"[DRY RUN] Would create {skill_dir}/SKILL.md")
            continue
        skill_dir.mkdir(parents=True, exist_ok=True)
        skill_md = generate_skill(skill_name, title, content, metadata)
        (skill_dir / "SKILL.md").write_text(skill_md)
        print(f"Generated {skill_name}")
    
    # Generate research gaps skill
    if gaps_content:
        skill_name = "feudal-game-plugin-research-gaps"
        skill_dir = SKILLS_DIR / skill_name
        if args.dry_run:
            print(f"[DRY RUN] Would create {skill_dir}/SKILL.md")
        else:
            skill_dir.mkdir(parents=True, exist_ok=True)
            frontmatter = f"""---
name: {skill_name}
description: Critical information missing and further investigation needed for Godot plugins in feudal game development.
license: N/A
compatibility: Godot 4.x, Feudal Game project
metadata:
  source: "Research report plugin-deep-research.md"
  section: "Research Gaps & Next Steps"
tags:
  - godot
  - plugin
  - research
---
"""
            skill_md = frontmatter + "\n" + gaps_content + "\n"
            (skill_dir / "SKILL.md").write_text(skill_md)
            print(f"Generated {skill_name}")
    
    print("\nDone.")
    return 0

if __name__ == "__main__":
    sys.exit(main())