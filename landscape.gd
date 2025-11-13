extends Node3D
# Godot 4.5 — Heightmap terrain (bilinear sampling + smooth normals), fully typed

@export var grid: int = 256
@export var cell: float = 1.0
@export var height_scale: float = 60.0
@export var heightmap: Texture2D

@export var albedo_texture: Texture2D
@export var uv_scale: Vector2 = Vector2(10.0, 10.0)

@export var add_noise: bool = false
@export var noise_strength: float = 6.0
@export var noise_freq: float = 0.02
@export var noise_seed: int = 1337

# ---------- Internals ----------
var _img: Image = null
var _use_noise: bool = false
var _noise: FastNoiseLite

func _ready() -> void:
	# Prepare height source
	if heightmap != null:
		_img = heightmap.get_image()
		if _img.is_compressed():
			_img.decompress()
		_img.convert(Image.FORMAT_RGBA8)

	# Optional noise
	_use_noise = add_noise
	if _use_noise:
		_noise = FastNoiseLite.new()
		_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		_noise.frequency = noise_freq
		_noise.seed = noise_seed

	# --- Precompute heights ---
	var H: PackedFloat32Array = PackedFloat32Array()
	H.resize(grid * grid)
	for z in range(grid):
		for x in range(grid):
			H[z * grid + x] = _sample_h(x, z)

	# --- Build mesh (fully typed locals) ---
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(grid - 1):
		for x in range(grid - 1):
			var xw: float  = (float(x)         - float(grid - 1) * 0.5) * cell
			var xw1: float = (float(x + 1)     - float(grid - 1) * 0.5) * cell
			var zw: float  = (float(z)         - float(grid - 1) * 0.5) * cell
			var zw1: float = (float(z + 1)     - float(grid - 1) * 0.5) * cell

			var p00: Vector3 = Vector3(xw,  H[z * grid + x],           zw)
			var p10: Vector3 = Vector3(xw1, H[z * grid + x + 1],       zw)
			var p01: Vector3 = Vector3(xw,  H[(z + 1) * grid + x],     zw1)
			var p11: Vector3 = Vector3(xw1, H[(z + 1) * grid + x + 1], zw1)

			var n00: Vector3 = _normal_at(x, z, H)
			var n10: Vector3 = _normal_at(x + 1, z, H)
			var n01: Vector3 = _normal_at(x, z + 1, H)
			var n11: Vector3 = _normal_at(x + 1, z + 1, H)

			var u0: float = float(x) / float(grid - 1)
			var v0: float = float(z) / float(grid - 1)
			var u1: float = float(x + 1) / float(grid - 1)
			var v1: float = float(z + 1) / float(grid - 1)

			# tri 1: p00, p10, p01
			st.set_normal(n00); st.set_uv(Vector2(u0, v0) * uv_scale); st.add_vertex(p00)
			st.set_normal(n10); st.set_uv(Vector2(u1, v0) * uv_scale); st.add_vertex(p10)
			st.set_normal(n01); st.set_uv(Vector2(u0, v1) * uv_scale); st.add_vertex(p01)
			# tri 2: p10, p11, p01
			st.set_normal(n10); st.set_uv(Vector2(u1, v0) * uv_scale); st.add_vertex(p10)
			st.set_normal(n11); st.set_uv(Vector2(u1, v1) * uv_scale); st.add_vertex(p11)
			st.set_normal(n01); st.set_uv(Vector2(u0, v1) * uv_scale); st.add_vertex(p01)

	var mesh: ArrayMesh = st.commit() as ArrayMesh

	# Reuse or create a MeshInstance3D named "Landscape"
	var landscape_mi: MeshInstance3D = get_node_or_null("Landscape") as MeshInstance3D
	if landscape_mi == null:
		landscape_mi = MeshInstance3D.new()
		landscape_mi.name = "Landscape"
		add_child(landscape_mi)
	landscape_mi.mesh = mesh

	# Material
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.roughness = 1.0
	mat.albedo_color = Color(0.18, 0.42, 0.20)
	if albedo_texture != null:
		mat.albedo_texture = albedo_texture
	landscape_mi.material_override = mat

	# Drop terrain slightly so road hovers
	position.y = -4.0


func _luma(c: Color) -> float:
	return c.r * 0.299 + c.g * 0.587 + c.b * 0.114

func _sample_h(ix: int, iz: int) -> float:
	var extra: float = 0.0
	if _use_noise:
		extra = _noise.get_noise_2d(
			float(ix) / float(grid - 1),
			float(iz) / float(grid - 1)
		) * noise_strength

	if _img == null:
		return (extra * 0.5 + 0.5) * height_scale

	var w: int = _img.get_width()
	var h: int = _img.get_height()
	var u: float = float(ix) / float(grid - 1) * float(w - 1)
	var v: float = float(iz) / float(grid - 1) * float(h - 1)

	var x0: int = clampi(int(floor(u)), 0, w - 1)
	var y0: int = clampi(int(floor(v)), 0, h - 1)
	var x1: int = clampi(x0 + 1, 0, w - 1)
	var y1: int = clampi(y0 + 1, 0, h - 1)
	var fu: float = u - float(x0)
	var fv: float = v - float(y0)

	var c00: float = _luma(_img.get_pixel(x0, y0))
	var c10: float = _luma(_img.get_pixel(x1, y0))
	var c01: float = _luma(_img.get_pixel(x0, y1))
	var c11: float = _luma(_img.get_pixel(x1, y1))

	var c0: float = lerp(c00, c10, fu)
	var c1: float = lerp(c01, c11, fu)
	var hmap: float = lerp(c0, c1, fv)  # 0..1

	return hmap * height_scale + extra

func _normal_at(ix: int, iz: int, H: PackedFloat32Array) -> Vector3:
	var xm: int = max(ix - 1, 0)
	var xp: int = min(ix + 1, grid - 1)
	var zm: int = max(iz - 1, 0)
	var zp: int = min(iz + 1, grid - 1)

	var hL: float = H[iz * grid + xm]
	var hR: float = H[iz * grid + xp]
	var hD: float = H[zm * grid + ix]
	var hU: float = H[zp * grid + ix]

	var dx: float = (hR - hL) / (2.0 * cell)
	var dz: float = (hU - hD) / (2.0 * cell)
	return Vector3(-dx, 1.0, -dz).normalized()
