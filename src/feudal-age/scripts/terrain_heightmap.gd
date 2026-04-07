@tool
extends MeshInstance3D


@export var mesh_resolution: int = 64:
	set(v):
		mesh_resolution = v
		_build_mesh()
@export var terrain_size: float = 80.0:
	set(v):
		terrain_size = v
		_build_mesh()
@export var terrain_height: float = 5.0:
	set(v):
		terrain_height = v
		_build_mesh()
@export var noise_scale: float = 20.0:
	set(v):
		noise_scale = v
		_build_mesh()
@export var noise_seed: int = 42:
	set(v):
		noise_seed = v
		_build_mesh()


func _ready():
	_build_mesh()


func _build_mesh():
	var terrain_noise = FastNoiseLite.new()
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	terrain_noise.seed = noise_seed
	terrain_noise.frequency = 1.0 / noise_scale

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(null)

	var color_low  = Color(0.15, 0.45, 0.08)    # dark green
	var color_high = Color(0.50, 0.40, 0.25)     # brown

	var w = mesh_resolution
	var h = mesh_resolution
	var dx = terrain_size / w
	var dz = terrain_size / h

	for row in range(h):
		for col in range(w):
			var x0 = (col * dx) - terrain_size * 0.5
			var z0 = (row * dz) - terrain_size * 0.5
			var x1 = ((col + 1) * dx) - terrain_size * 0.5
			var z1 = ((row + 1) * dz) - terrain_size * 0.5

			var y00 = terrain_noise.get_noise_2d(x0, z0) * terrain_height
			var y10 = terrain_noise.get_noise_2d(x1, z0) * terrain_height
			var y01 = terrain_noise.get_noise_2d(x0, z1) * terrain_height
			var y11 = terrain_noise.get_noise_2d(x1, z1) * terrain_height

			var h00 = (y00 + terrain_height) / (terrain_height * 2.0)
			var h10 = (y10 + terrain_height) / (terrain_height * 2.0)
			var h01 = (y01 + terrain_height) / (terrain_height * 2.0)
			var h11 = (y11 + terrain_height) / (terrain_height * 2.0)

			var c00 = color_low.lerp(color_high, h00)
			var c10 = color_low.lerp(color_high, h10)
			var c01 = color_low.lerp(color_high, h01)
			var c11 = color_low.lerp(color_high, h11)

			# Triangle 1 (clockwise winding = normal facing up/Y+)
			st.set_color(c00)
			st.add_vertex(Vector3(x0, y00, z0))
			st.set_color(c10)
			st.add_vertex(Vector3(x1, y10, z0))
			st.set_color(c01)
			st.add_vertex(Vector3(x0, y01, z1))

			# Triangle 2
			st.set_color(c10)
			st.add_vertex(Vector3(x1, y10, z0))
			st.set_color(c11)
			st.add_vertex(Vector3(x1, y11, z1))
			st.set_color(c01)
			st.add_vertex(Vector3(x0, y01, z1))

	mesh = st.commit()
