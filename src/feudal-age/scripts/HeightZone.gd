@tool
class_name HeightZone
extends Resource

## A label for identifying this zone in the inspector.
@export var label: String = "Zone"

## The texture slot index in Terrain3DAssets (0–31).
@export_range(0, 31) var texture_id: int = 0

## The minimum elevation for this zone in world units.
@export var min_height: float = 0.0

## The maximum elevation for this zone in world units.
@export var max_height: float = 50.0
