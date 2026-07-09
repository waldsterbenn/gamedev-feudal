@tool
class_name TextureMapGenerator
extends Node

## The Terrain3D node to paint. Assign in the inspector.
@export var terrain: Terrain3D

## One entry per elevation band. Can overlap — blend_width handles the transition.
@export var height_zones: Array[HeightZone] = []

## World-unit width of the cross-fade region between adjacent height zones.
## A value of 5 means ±2.5 units around each zone boundary is blended.
@export_range(0.0, 50.0, 0.5) var blend_width: float = 5.0

## UV Scale index to use for generated pixels (0-7).
## 0 = -60%, 3 = 0% (1.0x), 7 = +80%
@export_range(0, 7) var uv_scale_index: int = 0

## Slope angle (degrees from vertical) above which autoshader takes over.
## 0 = all terrain auto-shaded; 90 = autoshader never used.
@export_range(0.0, 90.0, 1.0) var slope_threshold: float = 35.0

## Editor-only button — calls generate() when clicked.
@export_tool_button("Generate Texture Map", "Terrain3D")
var _generate_btn: Callable = generate


## Signal emitted when a full generation pass is finished.
signal generation_completed


## Regenerate the full control map based on height_zones and slope_threshold.
func generate() -> void:
	if not _validate_setup():
		return
	
	print("TextureMapGenerator: Starting full generation...")
	
	# 1. Sort height_zones by min_height ascending
	var sorted_zones: Array[HeightZone] = height_zones.duplicate()
	sorted_zones.sort_custom(func(a: HeightZone, b: HeightZone) -> bool:
		return a.min_height < b.min_height
	)
	
	# 2. Iterate through regions
	var active_regions: Array = terrain.data.get_regions_active()
	for region in active_regions:
		_generate_region(region, sorted_zones)
	
	# 3. Rebuild GPU texture arrays for control map only, edited regions only
	terrain.data.update_maps(Terrain3DRegion.TYPE_CONTROL, false)
	
	# 4. Clear edited flags after update
	for region in active_regions:
		region.set_edited(false)
		
	generation_completed.emit()
	print("TextureMapGenerator: Generation completed.")


## Regenerate only the region that contains world_pos.
func generate_at(world_pos: Vector3) -> void:
	if not _validate_setup():
		return
	
	var region_location: Vector2i = terrain.data.get_region_location(world_pos)
	var region: Terrain3DRegion = terrain.data.get_region(region_location)
	if not region:
		push_warning("TextureMapGenerator: world_pos is outside any active region.")
		return
		
	var sorted_zones: Array[HeightZone] = height_zones.duplicate()
	sorted_zones.sort_custom(func(a: HeightZone, b: HeightZone) -> bool:
		return a.min_height < b.min_height
	)
	
	_generate_region(region, sorted_zones)
	terrain.data.update_maps(Terrain3DRegion.TYPE_CONTROL, false)
	region.set_edited(false)


## Regenerate a specific region by its location index.
func generate_region(region_location: Vector2i) -> void:
	if not _validate_setup():
		return
		
	var region: Terrain3DRegion = terrain.data.get_region(region_location)
	if not region:
		push_warning("TextureMapGenerator: No region found at ", region_location)
		return
		
	var sorted_zones: Array[HeightZone] = height_zones.duplicate()
	sorted_zones.sort_custom(func(a: HeightZone, b: HeightZone) -> bool:
		return a.min_height < b.min_height
	)
	
	_generate_region(region, sorted_zones)
	terrain.data.update_maps(Terrain3DRegion.TYPE_CONTROL, false)
	region.set_edited(false)


## Internal: Process a single region.
func _generate_region(region: Terrain3DRegion, sorted_zones: Array[HeightZone]) -> void:
	var control_img: Image = region.get_map(Terrain3DRegion.TYPE_CONTROL)
	var height_img: Image = region.get_map(Terrain3DRegion.TYPE_HEIGHT)
	var region_size: int = region.region_size
	var vertex_spacing: float = region.vertex_spacing
	
	for x in range(region_size):
		for y in range(region_size):
			var height: float = height_img.get_pixel(x, y).r
			var slope_deg: float = _calc_slope(height_img, x, y, vertex_spacing)
			
			var new_uint: int = _encode_control_pixel(height, slope_deg, sorted_zones)
			# Reinterpret uint as float for storage in FORMAT_RF image
			var new_color: Color = Color(Terrain3DUtil.as_float(new_uint), 0.0, 0.0, 1.0)
			control_img.set_pixel(x, y, new_color)
			
	region.set_modified(true)
	region.set_edited(true)


## Internal: Calculate slope in degrees at a specific point.
func _calc_slope(height_img: Image, x: int, y: int, vertex_spacing: float) -> float:
	var size: int = height_img.get_width()
	var h_l: float = height_img.get_pixel(max(x - 1, 0), y).r
	var h_r: float = height_img.get_pixel(min(x + 1, size - 1), y).r
	var h_d: float = height_img.get_pixel(x, max(y - 1, 0)).r
	var h_u: float = height_img.get_pixel(x, min(y + 1, size - 1)).r
	
	var dx: float = (h_r - h_l) / (2.0 * vertex_spacing)
	var dy: float = (h_u - h_d) / (2.0 * vertex_spacing)
	
	var normal: Vector3 = Vector3(-dx, 1.0, -dy).normalized()
	return rad_to_deg(acos(clamp(normal.dot(Vector3.UP), -1.0, 1.0)))


## Internal: Determine texture assignments and blending based on height and slope.
func _encode_control_pixel(height: float, slope_deg: float, sorted_zones: Array[HeightZone]) -> int:
	# UV bits set to uv_scale_index.
	# Index 0 corresponds to -60% in the Terrain3D editor UI.
	var uv_bits: int = Terrain3DUtil.enc_uv_scale(uv_scale_index) | Terrain3DUtil.enc_uv_rotation(0)
	
	# 1. Slope Check (Hard-coded rock for steep slopes to avoid expensive GPU Autoshader)
	if slope_deg >= slope_threshold:
		var rock_id: int = 4 # Index of Meadow_Rock_Base in terrain_assets.tres
		return Terrain3DUtil.enc_base(rock_id) | uv_bits
	
	# 2. Height-based blending
	var zone_info: Dictionary = _find_zones_and_blend(height, sorted_zones)
	var zone_a: HeightZone = zone_info["zone_a"]
	var zone_b: HeightZone = zone_info["zone_b"]
	var blend_t: float = zone_info["blend_t"]
	
	var base_id: int = zone_a.texture_id
	
	# Optimization: If no blend is needed, only set the base texture
	if zone_b == null or blend_t <= 0.01:
		return Terrain3DUtil.enc_base(base_id) | uv_bits
	
	var overlay_id: int = zone_b.texture_id
	var blend_byte: int = int(blend_t * 255.0)
	
	return Terrain3DUtil.enc_base(base_id) \
		| Terrain3DUtil.enc_overlay(overlay_id) \
		| Terrain3DUtil.enc_blend(blend_byte) \
		| uv_bits


## Internal: Find the two zones for blending and the blend factor.
## Prioritizes natural overlaps between zones.
func _find_zones_and_blend(height: float, sorted_zones: Array[HeightZone]) -> Dictionary:
	# Check if we are below the first zone's range
	if height < sorted_zones[0].min_height:
		return {"zone_a": sorted_zones[0], "zone_b": null, "blend_t": 0.0}

	for i in range(sorted_zones.size() - 1):
		var zone_a: HeightZone = sorted_zones[i]
		var zone_b: HeightZone = sorted_zones[i+1]
		
		# Define the transition window
		var t_start: float
		var t_end: float
		
		if zone_b.min_height < zone_a.max_height:
			# Overlap: use the overlap itself as the blend region
			t_start = zone_b.min_height
			t_end = zone_a.max_height
		else:
			# Gap or Abutting: use blend_width around the midpoint
			var midpoint: float = (zone_a.max_height + zone_b.min_height) * 0.5
			t_start = midpoint - blend_width * 0.5
			t_end = midpoint + blend_width * 0.5
			
		# Guard against division by zero if t_start == t_end
		if is_equal_approx(t_start, t_end):
			t_end += 0.001
			
		if height < t_start:
			# If we are below the next transition, and we are above the first zone's min,
			# then we are strictly in zone_a (or a previous transition already handled).
			# Since we iterate upwards, the first zone_a that satisfies height < t_start wins.
			return {"zone_a": zone_a, "zone_b": null, "blend_t": 0.0}
			
		if height <= t_end:
			# In transition!
			var t: float = (height - t_start) / (t_end - t_start)
			return {"zone_a": zone_a, "zone_b": zone_b, "blend_t": clamp(t, 0.0, 1.0)}

	# Above all transitions
	return {"zone_a": sorted_zones.back(), "zone_b": null, "blend_t": 0.0}


## Internal: Get the texture_id of the zone height is currently in.
func _get_nearest_zone_id(height: float, sorted_zones: Array[HeightZone]) -> int:
	for i in range(sorted_zones.size()):
		if height <= sorted_zones[i].max_height:
			return sorted_zones[i].texture_id
	return sorted_zones.back().texture_id


## Internal validation check.
func _validate_setup() -> bool:
	# Attempt to find sibling Terrain3D if not assigned
	if not terrain:
		var parent = get_parent()
		if parent:
			terrain = parent.find_child("Terrain3D", true, false)
			
	if not terrain:
		push_warning("TextureMapGenerator: No Terrain3D node assigned or found as a sibling.")
		return false
	if not terrain.data:
		push_warning("TextureMapGenerator: Terrain3D has no data.")
		return false
	if height_zones.is_empty():
		push_warning("TextureMapGenerator: No height zones defined.")
		return false
	return true
