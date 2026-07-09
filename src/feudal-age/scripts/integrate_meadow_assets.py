import os
import shutil

# Paths
SOURCE_DIR = "Assets/Synthy/SynthyNatureBiomesMeadowForestPackage/POLYGON_NatureBiomes_MeadowForest_SourceFiles_v2/Meadow_Source_Files/Textures/Terrain/"
DEST_DIR = "src/feudal-age/assets/textures/meadow/"

# Ensure destination exists
os.makedirs(DEST_DIR, exist_ok=True)

# Selected textures (Texture name, Normal name, Resource name)
ASSETS = [
    ("Grass_Texture_01.png", "Ground_Normals_01.png", "Meadow_Grass_Base"),
    ("Grass_Clovers_Texture_01.png", "Ground_Clovers_Normals_01.png", "Meadow_Grass_Clovers"),
    ("Grass_Flowers_Texture_01.png", "Ground_Flowers_Normals_01.png", "Meadow_Grass_Flowers"),
    ("Dirt_Texture_01.png", "Dirt_Normals_01.png", "Meadow_Dirt_Base"),
    ("Rock_Texture_01.png", "Rock_Normals_01.png", "Meadow_Rock_Base"),
    ("Rock_Moss_Texture_01.png", "Rock_Moss_Normals.png", "Meadow_Rock_Mossy"),
    ("Gravel_Texture_01.png", "Gravel_Normals_01.png", "Meadow_Gravel"),
    ("Cobblestone_Texture_01.png", "Cobblestone_Normals_01.png", "Meadow_Cobblestone"),
    ("Moss_Texture_01.png", "Moss_Normals_01.png", "Meadow_Moss"),
    ("Leaves_Texture_01.png", "Leaves_Normals_01.png", "Meadow_Leaves"),
]

print("Copying assets and generating .tres files...")
for tex, norm, res_name in ASSETS:
    # Copy texture
    src_tex = os.path.join(SOURCE_DIR, tex)
    dest_tex = os.path.join(DEST_DIR, tex)
    if os.path.exists(src_tex):
        shutil.copy2(src_tex, dest_tex)
        print(f"  Copied: {tex}")
    else:
        print(f"  Warning: Source not found: {src_tex}")
        
    # Copy normal
    src_norm = os.path.join(SOURCE_DIR, norm)
    dest_norm = os.path.join(DEST_DIR, norm)
    if os.path.exists(src_norm):
        shutil.copy2(src_norm, dest_norm)
        print(f"  Copied: {norm}")
    else:
        print(f"  Warning: Source not found: {src_norm}")

    # Generate .tres file content
    tres_content = f"""[gd_resource type="Terrain3DTextureAsset" load_steps=3 format=3]

[ext_resource type="Texture2D" path="res://assets/textures/meadow/{tex}" id="1_tex"]
[ext_resource type="Texture2D" path="res://assets/textures/meadow/{norm}" id="2_norm"]

[resource]
name = "{res_name.replace('_', ' ')}"
albedo_texture = ExtResource("1_tex")
normal_texture = ExtResource("2_norm")
uv_scale = 0.1
detiling = 0.2
"""
    res_path = os.path.join(DEST_DIR, f"{res_name}.tres")
    with open(res_path, "w") as f:
        f.write(tres_content)
    print(f"  Generated: {res_name}.tres")

print("Asset integration complete.")
