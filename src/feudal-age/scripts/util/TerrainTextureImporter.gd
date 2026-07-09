@tool
extends Node

## TerrainTextureImporter
## Utility to pack PBR textures and add them to the Terrain3DAssets library.

@export_group("Asset Info")
@export var asset_name: String = "NewTexture"
@export var target_slot: int = -1 # -1 to find next available

@export_group("Source Textures (Global Assets)")
@export var albedo_src: Texture2D
@export var height_src: Texture2D
@export var normal_src: Texture2D
@export var roughness_src: Texture2D

@export_group("Texture Settings")
@export var uv_scale: float = 0.1
@export var detiling: float = 0.2
@export var invert_normal_y: bool = false # Set to true if source is DirectX
@export var invert_roughness: bool = false # Set to true if source is Smoothness/Gloss

@export_group("Execution")
@export_tool_button("Pack and Import Texture", "Callable") var import_button = run_import

const HUB_DIR = "res://assets/terrain3d/"
const TEXTURE_DIR = HUB_DIR + "textures/"
const ASSETS_PATH = HUB_DIR + "terrain_assets.tres"

func run_import() -> void:
	if asset_name.is_empty():
		push_error("Importer: Please provide an asset name.")
		return
	
	if not albedo_src or not normal_src:
		push_error("Importer: Albedo and Normal textures are mandatory.")
		return

	print("Importer: Starting import for '", asset_name, "'...")

	# 1. Pack Textures
	var packed_alb: Image = _pack_albedo_height()
	var packed_nrm: Image = _pack_normal_roughness()
	
	if not packed_alb or not packed_nrm:
		return

	# 2. Save PNGs to Hub
	var safe_name = asset_name.to_snake_case()
	var alb_path = TEXTURE_DIR + safe_name + "_alb_ht.png"
	var nrm_path = TEXTURE_DIR + safe_name + "_nrm_rh.png"
	
	# Ensure directory exists (in case it's missing)
	DirAccess.make_dir_recursive_absolute(TEXTURE_DIR)
	
	packed_alb.save_png(alb_path)
	packed_nrm.save_png(nrm_path)
	print("Importer: Saved packed textures to ", TEXTURE_DIR)

	# 3. Create/Update Terrain3DTextureAsset
	var tex_asset := Terrain3DTextureAsset.new()
	tex_asset.name = asset_name
	tex_asset.albedo_texture = load(alb_path)
	tex_asset.normal_texture = load(nrm_path)
	tex_asset.uv_scale = uv_scale
	# detiling is not a property on TextureAsset directly in latest versions, 
	# it uses rotation/shift. Setting common defaults.
	
	# 4. Add to Main Library
	_add_to_library(tex_asset)

func _pack_albedo_height() -> Image:
	var alb_img = albedo_src.get_image()
	var ht_img = height_src.get_image() if height_src else null
	
	if not ht_img:
		# Create a 50% grey heightmap if none provided
		ht_img = Image.create_empty(alb_img.get_width(), alb_img.get_height(), false, Image.FORMAT_L8)
		ht_img.fill(Color(0.5, 0.5, 0.5, 1.0))
	
	return Terrain3DUtil.pack_image(alb_img, ht_img, false, false, true, 0)

func _pack_normal_roughness() -> Image:
	var nrm_img = normal_src.get_image()
	var rh_img = roughness_src.get_image() if roughness_src else null
	
	if not rh_img:
		# Create a 50% roughness map if none provided
		rh_img = Image.create_empty(nrm_img.get_width(), nrm_img.get_height(), false, Image.FORMAT_L8)
		rh_img.fill(Color(0.5, 0.5, 0.5, 1.0))
	
	return Terrain3DUtil.pack_image(nrm_img, rh_img, invert_normal_y, invert_roughness, false, 0)

func _add_to_library(new_tex: Terrain3DTextureAsset) -> void:
	var assets: Terrain3DAssets
	if FileAccess.file_exists(ASSETS_PATH):
		assets = load(ASSETS_PATH)
	else:
		assets = Terrain3DAssets.new()
	
	# Find slot
	var slot = target_slot
	if slot < 0:
		slot = assets.get_texture_count()
	
	new_tex.id = slot
	assets.set_texture(slot, new_tex)
	
	var err = ResourceSaver.save(assets, ASSETS_PATH)
	if err == OK:
		print("Importer: Successfully added '", asset_name, "' to slot ", slot, " in ", ASSETS_PATH)
		print("!!! IMPORTANT: You must manually set 'Normal Map' to 'Disabled' and 'Mipmaps' to 'On' in the Import tab for the new PNGs, then click Reimport. !!!")
	else:
		push_error("Importer: Failed to save assets resource. Error: ", err)
