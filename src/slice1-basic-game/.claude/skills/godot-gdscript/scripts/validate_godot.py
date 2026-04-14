#!/usr/bin/env python3
"""
Godot 4.x file validator for Claude Code.
Validates .tscn, .tres, and .gd files for common structural errors.

Usage:
    python validate_godot.py <file>
    python validate_godot.py --all          # validate entire project
    python validate_godot.py scene.tscn
    python validate_godot.py resource.tres
    python validate_godot.py script.gd
"""

import sys
import os
import re
from pathlib import Path

PASS = "\033[92m✓\033[0m"
FAIL = "\033[91m✗\033[0m"
WARN = "\033[93m⚠\033[0m"

errors = []
warnings = []

def error(msg: str):
    errors.append(msg)
    print(f"  {FAIL} ERROR: {msg}")

def warn(msg: str):
    warnings.append(msg)
    print(f"  {WARN} WARN:  {msg}")

def ok(msg: str):
    print(f"  {PASS} {msg}")


# ─── TSCN / TRES validator ────────────────────────────────────────────────────

def validate_scene_resource(path: Path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    is_tscn = path.suffix == ".tscn"
    is_tres = path.suffix == ".tres"

    print(f"\n{'Scene' if is_tscn else 'Resource'}: {path}")

    # 1. Header check
    header = lines[0] if lines else ""
    if is_tscn and not header.startswith("[gd_scene"):
        error(f"First line must start with [gd_scene ...], got: {header!r}")
    elif is_tres and not header.startswith("[gd_resource"):
        error(f"First line must start with [gd_resource ...], got: {header!r}")
    else:
        ok("Header format correct")

    # 2. format=3 check (Godot 4)
    if "format=3" not in header:
        if "format=2" in header:
            error("format=2 detected — this is a Godot 3 file. Must be format=3 for Godot 4")
        else:
            warn("No format=3 in header — Godot 4 files should have format=3")
    else:
        ok("format=3 present (Godot 4)")

    # 3. Collect declared ext_resource IDs
    ext_ids: dict[str, str] = {}
    ext_resource_count = 0
    for line in lines:
        m = re.match(r'\[ext_resource\s+.*?id="([^"]+)"', line)
        if m:
            ext_ids[m.group(1)] = line.strip()
            ext_resource_count += 1

    # 4. Collect declared sub_resource IDs
    sub_ids: dict[str, str] = {}
    sub_resource_count = 0
    for line in lines:
        m = re.match(r'\[sub_resource\s+.*?id="([^"]+)"', line)
        if m:
            sub_ids[m.group(1)] = line.strip()
            sub_resource_count += 1

    # 5. load_steps check
    m_steps = re.search(r'load_steps=(\d+)', header)
    if m_steps:
        declared = int(m_steps.group(1))
        expected = ext_resource_count + sub_resource_count + 1
        if declared != expected:
            error(
                f"load_steps={declared} but counted {ext_resource_count} ext_resource "
                f"+ {sub_resource_count} sub_resource + 1 = {expected}. "
                f"Fix: load_steps={expected}"
            )
        else:
            ok(f"load_steps={declared} matches resource count")
    else:
        warn("No load_steps in header")

    # 6. ExtResource references match declared IDs
    used_ext: list[str] = re.findall(r'ExtResource\("([^"]+)"\)', text)
    for used_id in used_ext:
        if used_id not in ext_ids:
            error(f'ExtResource("{used_id}") used but never declared as [ext_resource]')
    if ext_ids:
        ok(f"{len(ext_ids)} ext_resource(s) declared, all references valid")

    # 7. SubResource references match declared IDs
    used_sub: list[str] = re.findall(r'SubResource\("([^"]+)"\)', text)
    for used_id in used_sub:
        if used_id not in sub_ids:
            error(f'SubResource("{used_id}") used but never declared as [sub_resource]')
    if sub_ids:
        ok(f"{len(sub_ids)} sub_resource(s) declared, all references valid")

    # 8. Forbidden GDScript syntax inside .tscn / .tres
    gdscript_patterns = [
        (r'\bpreload\s*\(', "preload() is GDScript — use ExtResource() instead"),
        (r'^(var|const|func|class|signal|enum)\b', "GDScript keyword found — not valid in .tscn/.tres"),
        (r'^\s*@export\b', "@export is GDScript — not valid in .tscn/.tres"),
        (r'^\s*@onready\b', "@onready is GDScript — not valid in .tscn/.tres"),
    ]
    found_gdscript = False
    for i, line in enumerate(lines, 1):
        for pattern, msg in gdscript_patterns:
            if re.search(pattern, line):
                error(f"Line {i}: {msg}\n    → {line.strip()}")
                found_gdscript = True
    if not found_gdscript:
        ok("No forbidden GDScript syntax found")

    # 9. TSCN-specific: root node has no parent, parenting structure
    if is_tscn:
        node_lines = [(i+1, l) for i, l in enumerate(lines) if l.startswith("[node")]
        if not node_lines:
            error("No [node] entries found — scene has no nodes")
        else:
            # Root node check
            first_node_line = node_lines[0][1]
            if "parent=" in first_node_line:
                error(
                    f"Root node must NOT have a parent= attribute\n"
                    f"    → {first_node_line.strip()}"
                )
            else:
                ok("Root node has no parent (correct)")

            # Collect all node names and parents for path validation
            declared_nodes: set[str] = set()
            root_name = re.search(r'name="([^"]+)"', first_node_line)
            if root_name:
                declared_nodes.add(root_name.group(1))

            for lineno, nline in node_lines[1:]:
                nm = re.search(r'name="([^"]+)"', nline)
                pm = re.search(r'parent="([^"]+)"', nline)
                if nm:
                    declared_nodes.add(nm.group(1))
                if pm:
                    parent_path = pm.group(1)
                    # Check root name is not embedded in parent path
                    if root_name and parent_path.startswith(root_name.group(1) + "/"):
                        error(
                            f"Line {lineno}: parent path must NOT include root node name\n"
                            f"    → {nline.strip()}\n"
                            f"    Fix: remove '{root_name.group(1)}/' prefix from parent"
                        )

            ok(f"{len(node_lines)} node(s) found")

    # 10. Godot 3 connect() syntax (old-style)
    old_connect = re.findall(r'connect\s*\(\s*"[^"]+"\s*,\s*self\s*,\s*"', text)
    if old_connect:
        error(f"Godot 3 connect() syntax detected ({len(old_connect)} occurrence(s)) — use signal.connect(callable)")
    else:
        ok("No Godot 3 connect() syntax")


# ─── GDScript validator ───────────────────────────────────────────────────────

def validate_gdscript(path: Path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    print(f"\nGDScript: {path}")

    # 1. extends present
    has_extends = any(l.startswith("extends ") for l in lines)
    if not has_extends:
        warn("No 'extends' found — is this a standalone script?")
    else:
        ok("'extends' found")

    # 2. Untyped variable declarations
    untyped_vars = []
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        # var x = ... without type hint (not @export, not @onready, not typed)
        if re.match(r'^var\s+\w+\s*=', stripped) and not re.match(r'^var\s+\w+\s*:', stripped):
            # skip dictionary/array literals that are hard to type inline
            untyped_vars.append((i, stripped))
    if untyped_vars:
        for lineno, l in untyped_vars[:5]:  # show first 5
            warn(f"Line {lineno}: Untyped var — add type hint\n    → {l}")
        if len(untyped_vars) > 5:
            warn(f"... and {len(untyped_vars) - 5} more untyped vars")
    else:
        ok("All var declarations appear typed")

    # 3. Untyped function signatures
    untyped_funcs = []
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if re.match(r'^func\s+\w+\s*\(', stripped):
            # no return type arrow
            if "->" not in stripped:
                untyped_funcs.append((i, stripped))
    if untyped_funcs:
        for lineno, l in untyped_funcs[:5]:
            warn(f"Line {lineno}: Function missing return type\n    → {l}")
        if len(untyped_funcs) > 5:
            warn(f"... and {len(untyped_funcs) - 5} more untyped functions")
    else:
        ok("All functions have return types")

    # 4. Godot 3 patterns
    godot3_patterns = [
        (r'\byield\s*\(', "yield() is Godot 3 — use 'await' instead"),
        (r'\.connect\s*\(\s*"[^"]+"\s*,\s*self\s*,\s*"', "Old connect() syntax — use signal.connect(callable)"),
        (r'\bemit_signal\s*\(', "emit_signal() is Godot 3 — use signal_name.emit()"),
        (r'(?<!@)\bonready\s+var\b', "'onready var' is Godot 3 — use '@onready var'"),
        (r'(?<!@)\bexport\s+var\b', "'export var' is Godot 3 — use '@export var'"),
        (r'get_node\s*\(\s*"[^"]*"\s*\)', "Prefer @onready over get_node() string paths"),
        (r'\bOS\.get_ticks_msec\b', "Consider Time.get_ticks_msec() in Godot 4"),
    ]
    found_g3 = False
    for i, line in enumerate(lines, 1):
        for pattern, msg in godot3_patterns:
            if re.search(pattern, line):
                error(f"Line {i}: {msg}\n    → {line.strip()}")
                found_g3 = True
    if not found_g3:
        ok("No Godot 3 syntax patterns found")

    # 5. Ungated free() (dangerous mid-physics)
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if re.search(r'(?<!\.)free\(\)', stripped) and "call_deferred" not in stripped:
            if "_physics_process" in "\n".join(lines[max(0,i-10):i]):
                warn(f"Line {i}: free() near physics_process — prefer queue_free() or call_deferred")

    # 6. Check @onready has explicit type
    onready_lines = [(i+1, l.strip()) for i, l in enumerate(lines) if "@onready" in l]
    untyped_onready = [(n, l) for n, l in onready_lines if ":" not in l]
    if untyped_onready:
        for lineno, l in untyped_onready:
            warn(f"Line {lineno}: @onready missing type hint\n    → {l}")
    elif onready_lines:
        ok(f"{len(onready_lines)} @onready declaration(s) all typed")


# ─── Entry point ─────────────────────────────────────────────────────────────

def validate_file(path: Path):
    if not path.exists():
        print(f"\n{FAIL} File not found: {path}")
        return

    if path.suffix in (".tscn", ".tres"):
        validate_scene_resource(path)
    elif path.suffix == ".gd":
        validate_gdscript(path)
    else:
        print(f"\n{WARN} Skipping {path} (not .tscn/.tres/.gd)")


def validate_project(root: Path):
    files = list(root.rglob("*.tscn")) + list(root.rglob("*.tres")) + list(root.rglob("*.gd"))
    # Exclude .godot cache directory
    files = [f for f in files if ".godot" not in f.parts]
    print(f"Found {len(files)} file(s) to validate in {root}")
    for f in sorted(files):
        validate_file(f)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    arg = sys.argv[1]

    if arg == "--all":
        root = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(".")
        validate_project(root)
    else:
        validate_file(Path(arg))

    print()
    if errors:
        print(f"\033[91m{'─'*50}")
        print(f"FAILED — {len(errors)} error(s), {len(warnings)} warning(s)")
        print(f"{'─'*50}\033[0m")
        sys.exit(1)
    elif warnings:
        print(f"\033[93m{'─'*50}")
        print(f"PASSED with {len(warnings)} warning(s)")
        print(f"{'─'*50}\033[0m")
    else:
        print(f"\033[92m{'─'*50}")
        print("PASSED — no issues found")
        print(f"{'─'*50}\033[0m")


if __name__ == "__main__":
    main()
