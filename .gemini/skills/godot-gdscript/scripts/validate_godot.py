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

def get_project_root(path: Path) -> Path:
    """Finds the directory containing project.godot by walking up from path."""
    curr = path.absolute().parent
    while curr != curr.parent:
        if (curr / "project.godot").exists():
            return curr
        curr = curr.parent
    return Path(".")

def validate_scene_resource(path: Path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    is_tscn = path.suffix == ".tscn"
    is_tres = path.suffix == ".tres"
    project_root = get_project_root(path)

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

    # 3. UID check
    if "uid=\"" not in header:
        warn("Resource missing UID in header")
    uid_file = path.with_suffix(path.suffix + ".uid")
    if not uid_file.exists():
        warn(f"Missing .uid file: {uid_file.name}")

    # 4. Collect and validate ext_resource
    ext_ids: dict[str, str] = {}
    ext_resource_count = 0
    for i, line in enumerate(lines, 1):
        m = re.match(r'\[ext_resource\s+.*?path="([^"]+)"\s+.*?id="([^"]+)"', line)
        if m:
            path_val = m.group(1)
            id_val = m.group(2)
            
            if id_val in ext_ids:
                error(f"Line {i}: Duplicate ext_resource ID '{id_val}'")
            
            ext_ids[id_val] = path_val
            ext_resource_count += 1
            
            # File existence check
            if path_val.startswith("res://"):
                rel_path = path_val.replace("res://", "")
                abs_path = project_root / rel_path
                if not abs_path.exists():
                    error(f"Line {i}: Referenced file does not exist: {path_val}")
            else:
                warn(f"Line {i}: ext_resource path should use res:// protocol: {path_val}")

    # 5. Collect declared sub_resource IDs
    sub_ids: dict[str, str] = {}
    sub_resource_count = 0
    for i, line in enumerate(lines, 1):
        m = re.match(r'\[sub_resource\s+.*?id="([^"]+)"', line)
        if m:
            id_val = m.group(1)
            if id_val in sub_ids:
                error(f"Line {i}: Duplicate sub_resource ID '{id_val}'")
            sub_ids[id_val] = line.strip()
            sub_resource_count += 1

    # 6. load_steps check
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
        warn("No load_steps in header")

    # 7. Resource references match declared IDs
    used_ext: list[str] = re.findall(r'ExtResource\("([^"]+)"\)', text)
    for used_id in used_ext:
        if used_id not in ext_ids:
            error(f'ExtResource("{used_id}") used but never declared as [ext_resource]')

    used_sub: list[str] = re.findall(r'SubResource\("([^"]+)"\)', text)
    for used_id in used_sub:
        if used_id not in sub_ids:
            error(f'SubResource("{used_id}") used but never declared as [sub_resource]')

    # 8. Forbidden GDScript syntax inside .tscn / .tres
    gdscript_patterns = [
        (r'\bpreload\s*\(', "preload() is GDScript — use ExtResource() instead"),
        (r'^(var|const|func|class|signal|enum)\b', "GDScript keyword found — not valid in .tscn/.tres"),
        (r'^\s*@export\b', "@export is GDScript — not valid in .tscn/.tres"),
        (r'^\s*@onready\b', "@onready is GDScript — not valid in .tscn/.tres"),
    ]
    for i, line in enumerate(lines, 1):
        for pattern, msg in gdscript_patterns:
            if re.search(pattern, line):
                error(f"Line {i}: {msg}\n    → {line.strip()}")

    # 9. TSCN-specific: root node, parenting, connections
    if is_tscn:
        node_lines = [(i+1, l) for i, l in enumerate(lines) if l.startswith("[node")]
        if not node_lines:
            error("No [node] entries found — scene has no nodes")
        else:
            first_node_line = node_lines[0][1]
            if "parent=" in first_node_line:
                error(f"Root node must NOT have a parent= attribute: {first_node_line.strip()}")

            root_name_match = re.search(r'name="([^"]+)"', first_node_line)
            root_name = root_name_match.group(1) if root_name_match else None

            for lineno, nline in node_lines[1:]:
                pm = re.search(r'parent="([^"]+)"', nline)
                if pm:
                    parent_path = pm.group(1)
                    if root_name and parent_path.startswith(root_name + "/"):
                        error(
                            f"Line {lineno}: parent path must NOT include root node name\n"
                            f"    → {nline.strip()}\n"
                            f"    Fix: remove '{root_name}/' prefix from parent"
                        )

    # 10. Connection (Signal) Validation
    # Map node paths to scripts
    node_to_script: dict[str, Path] = {}
    current_node = None
    for line in lines:
        nm = re.search(r'\[node name="([^"]+)"', line)
        pm = re.search(r'parent="([^"]+)"', line)
        if nm:
            name = nm.group(1)
            # Basic path: . for root, Name for children
            path_in_scene = "." if not pm else (pm.group(1) + "/" + name if pm.group(1) != "." else name)
            current_node = path_in_scene
        
        sm = re.search(r'script = ExtResource\("([^"]+)"\)', line)
        if sm and current_node and sm.group(1) in ext_ids:
            script_res_path = ext_ids[sm.group(1)]
            if script_res_path.startswith("res://"):
                script_abs_path = project_root / script_res_path.replace("res://", "")
                node_to_script[current_node] = script_abs_path

    # Validate connections
    connections = re.findall(r'\[connection\s+signal="([^"]+)"\s+from="([^"]+)"\s+to="([^"]+)"\s+method="([^"]+)"', text)
    for sig, src, dest, method in connections:
        if dest in node_to_script:
            script_path = node_to_script[dest]
            if script_path.exists():
                script_text = script_path.read_text(encoding="utf-8")
                # Very basic check: does the function definition exist?
                if f"func {method}" not in script_text:
                    error(f"Signal '{sig}' from '{src}' connects to non-existent method '{method}' in {script_path}")
                else:
                    ok(f"Signal '{sig}' -> {dest}.{method}() validated")
            else:
                warn(f"Cannot validate signal '{sig}': script {script_path} not found")
        elif dest == ".":
            # Root node check (already handled by node_to_script if current_node was ".")
            pass

    if connections:
        ok(f"Validated {len(connections)} signal connection(s)")

    # 11. Godot 3 connect() syntax (old-style)
    old_connect = re.findall(r'connect\s*\(\s*"[^"]+"\s*,\s*self\s*,\s*"', text)
    if old_connect:
        error(f"Godot 3 connect() syntax detected ({len(old_connect)} occurrence(s)) — use signal.connect(callable)")


# ─── GDScript validator ───────────────────────────────────────────────────────

def validate_gdscript(path: Path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    print(f"\nGDScript: {path}")

    # 1. extends present
    has_extends = any(l.startswith("extends ") for l in lines)
    if not has_extends:
        warn("No 'extends' found — is this a standalone script?")

    # 2. Typing checks
    untyped_vars = []
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if re.match(r'^var\s+\w+\s*=', stripped) and not re.match(r'^var\s+\w+\s*:', stripped):
            untyped_vars.append((i, stripped))
    if untyped_vars:
        for lineno, l in untyped_vars[:3]:
            warn(f"Line {lineno}: Untyped var — add type hint: {l}")
        if len(untyped_vars) > 3:
            warn(f"... and {len(untyped_vars) - 3} more untyped vars")

    untyped_funcs = []
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if re.match(r'^func\s+\w+\s*\(', stripped) and "->" not in stripped:
            untyped_funcs.append((i, stripped))
    if untyped_funcs:
        for lineno, l in untyped_funcs[:3]:
            warn(f"Line {lineno}: Function missing return type: {l}")

    # 3. Godot 3 patterns
    godot3_patterns = [
        (r'\byield\s*\(', "yield() is Godot 3 — use 'await' instead"),
        (r'\.connect\s*\(\s*"[^"]+"\s*,\s*self\s*,\s*"', "Old connect() syntax — use signal.connect(callable)"),
        (r'\bemit_signal\s*\(', "emit_signal() is Godot 3 — use signal_name.emit()"),
        (r'(?<!@)\bonready\s+var\b', "'onready var' is Godot 3 — use '@onready var'"),
        (r'(?<!@)\bexport\s+var\b', "'export var' is Godot 3 — use '@export var'"),
        (r'get_node\s*\(\s*"[^"]*"\s*\)', "Prefer @onready over get_node() string paths"),
    ]
    for i, line in enumerate(lines, 1):
        for pattern, msg in godot3_patterns:
            if re.search(pattern, line):
                error(f"Line {i}: {msg}\n    → {line.strip()}")

    # 4. Expensive Operations Audit
    project_root = get_project_root(path)
    expensive_funcs = ["_process", "_physics_process", "_input", "_unhandled_input", "_draw"]
    current_func = None
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        
        # res:// path existence check
        res_paths = re.findall(r'res://[^\s"\'\)]+', line)
        for rp in res_paths:
            # Clean up potential trailing chars from regex match
            clean_rp = rp.rstrip(".,;)]")
            rel_path = clean_rp.replace("res://", "")
            if not (project_root / rel_path).exists():
                error(f"Line {i}: Referenced file does not exist: {clean_rp}")

        m_func = re.match(r'^func\s+([a-zA-Z0-9_]+)', stripped)
        if m_func:
            current_func = m_func.group(1)
        elif line and not line[0].isspace():
            current_func = None
        
        if current_func in expensive_funcs:
            if re.search(r'(?<![\w])(?:\$|get_node\()', stripped):
                if not stripped.startswith("#"):
                    warn(f"Line {i}: Expensive operation '$' or 'get_node' inside {current_func}. Use @onready instead.")

    # 5. Check @onready has explicit type
    onready_lines = [(i+1, l.strip()) for i, l in enumerate(lines) if "@onready" in l]
    for lineno, l in onready_lines:
        if ":" not in l:
            warn(f"Line {lineno}: @onready missing type hint: {l}")

    # 6. Ungated free() (dangerous mid-physics)
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if re.search(r'(?<!\.)free\(\)', stripped) and "call_deferred" not in stripped:
            if "_physics_process" in "\n".join(lines[max(0,i-10):i]):
                warn(f"Line {i}: free() near physics_process — prefer queue_free() or call_deferred")



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
