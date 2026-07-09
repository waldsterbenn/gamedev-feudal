@tool
extends EditorScript

## CLI Terrain Texture Importer
## Designed for use by Gemini CLI to automate the PBR -> Terrain3D pipeline.
##
## Usage:
## godot --headless --path src/feudal-age -s scripts/util/cmd_import_texture.gd

# --- CONFIGURATION (AI will modify these values) ---
const ASSET_NAME = "REPLACE_NAME"
const ALBEDO_PATH = "REPLACE_ALBEDO"
const HEIGHT_PATH = "REPLACE_HEIGHT"
const NORMAL_PATH = "REPLACE_NORMAL"
const ROUGH_PATH = "REPLACE_ROUGH"
const UV_SCALE = 0.1
const INVERT_NORMAL_Y = false
const INVERT_ROUGHNESS = false
# --------------------------------------------------

const HUB_DIR = "res://assets/terrain3d/"
const TEXTURE_DIR = HUB_DIR + "textures/"
const ASSETS_PATH = HUB_DIR + "terrain_assets.tres"

func _run() -> void:
	if ASSET_NAME == "REPLACE_NAME":
		printerr("CMD_Importer: Error - Configuration not set.")
		return

	print("CMD_Importer: Starting import for '", ASSET_NAME, "'...")

	# 1. Load Source Images
	var alb_img := _load_img(ALBEDO_PATH)
	var nrm_img := _load_img(NORMAL_PATH)
	
	if not alb_img or not nrm_img:
		return

	var ht_img := _load_img(HEIGHT_PATH)
	var rh_img := _load_img(ROUGH_PATH)

	# 2. Pack Textures
	if not ht_img:
		ht_img = Image.create_empty(alb_img.get_width(), alb_img.get_height(), false, Image.FORMAT_L8)
		ht_img.fill(Color(0.5, 0.5, 0.5, 1.0))

	if not rh_img:
		rh_img = Image.create_empty(nrm_img.get_width(), nrm_img.get_height(), false, Image.FORMAT_L8)
		rh_img.fill(Color(0.5, 0.5, 0.5, 1.0))

	var packed_alb := Terrain3DUtil.pack_image(alb_img, ht_img, false, false, true, 0)
	var packed_nrm := Terrain3DUtil.pack_image(nrm_img, rh_img, INVERT_NORMAL_Y, INVERT_ROUGHNESS, false, 0)

	# 3. Save PNGs to Hub
	var safe_name = ASSET_NAME.to_snake_case()
	var hub_alb_path = TEXTURE_DIR + safe_name + "_alb_ht.png"
	var hub_nrm_path = TEXTURE_DIR + safe_name + "_nrm_rh.png"
	
	DirAccess.make_dir_recursive_absolute(TEXTURE_DIR)
	packed_alb.save_png(hub_alb_path)
	packed_nrm.save_png(hub_nrm_path)

	# 4. Update Library
	_update_library(hub_alb_path, hub_nrm_path)

func _load_img(path: String) -> Image:
	if path.is_empty() or "REPLACE_" in path:
		return null
	
	var img = Image.load_from_file(ProjectSettings.globalize_path(path))
	if not img:
		printerr("CMD_Importer: Failed to load image at ", path)
	return img

func _update_library(alb_p: String, nrm_p: String) -> void:
	var assets: Terrain3DAssets
	if FileAccess.file_exists(ASSETS_PATH):
		assets = load(ASSETS_PATH)
	else:
		assets = Terrain3DAssets.new()
	
	var tex_asset := Terrain3DTextureAsset.new()
	tex_asset.name = ASSET_NAME
	tex_asset.albedo_texture = load(alb_p)
	tex_asset.normal_texture = load(nrm_p)
	tex_asset.uv_scale = UV_SCALE
	
	var slot = assets.get_texture_count()
	tex_asset.id = slot
	assets.set_texture(slot, tex_asset)
	
	var err = ResourceSaver.save(assets, ASSETS_PATH)
	if err == OK:
		print("CMD_Importer: SUCCESS. Added '", ASSET_NAME, "' to slot ", slot)
	else:
		printerr("CMD_Importer: FAILED to save assets. Error: ", err)
