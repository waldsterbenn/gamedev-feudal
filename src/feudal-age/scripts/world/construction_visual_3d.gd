extends Node3D
class_name ConstructionVisual3D

## Drives a building's world visual from its BuildingInstance progress (#70):
## ghost at order time (translucent, small), grows and solidifies as
## construction advances, fully solid when complete.

@export var atlas_material: Material

const GHOST_SCALE := 0.35
const GHOST_ALPHA := 0.45

var _building: BuildingInstance
var _mesh: MeshInstance3D
var _ghost_material: StandardMaterial3D

func _ready() -> void:
	_mesh = _find_mesh(self)
	if _mesh and atlas_material:
		_mesh.set_surface_override_material(0, atlas_material)
		# Per-instance duplicate so the ghost alpha doesn't mutate the shared .tres
		if _ghost_material == null and atlas_material is StandardMaterial3D:
			_ghost_material = atlas_material.duplicate()
			_ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			_mesh.set_surface_override_material(0, _ghost_material)
	EventBus.day_ticked.connect(_on_day_ticked)

## Binds the live BuildingInstance so the visual tracks construction progress
func setup(building: BuildingInstance) -> void:
	_building = building
	_apply_progress()

func _on_day_ticked(_day: int) -> void:
	if _building:
		_apply_progress()

func _apply_progress() -> void:
	if _mesh == null:
		return
	var total: float = _building.blueprint.total_work_required if _building.blueprint else 1.0
	var t: float = clampf(_building.construction_progress / total, 0.0, 1.0)
	if _building.is_completed:
		t = 1.0
	var target_scale: float = lerpf(GHOST_SCALE, 1.0, t)
	scale = Vector3.ONE * target_scale
	if _ghost_material:
		var alpha: float = lerpf(GHOST_ALPHA, 1.0, t)
		_ghost_material.albedo_color.a = alpha
		# Opaque at completion (crisper lighting, no blend cost)
		if alpha >= 1.0:
			_mesh.set_surface_override_material(0, atlas_material)
		else:
			_mesh.set_surface_override_material(0, _ghost_material)

func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := _find_mesh(child)
		if found:
			return found
	return null
