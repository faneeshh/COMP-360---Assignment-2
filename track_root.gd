extends Node3D

@onready var path: Path3D = $TrackPath
@onready var follow: PathFollow3D = $TrackPath/CarFollow
@onready var car: MeshInstance3D = $TrackPath/CarFollow/CarMesh
@onready var speed_label: Label = $UI/SpeedLabel

# --- AI tuning ---
@export var target_speed: float = 10.0        # forward speed
@export var lateral_speed: float = 6.0
@export var track_half_width: float = 4.0    # half-width of the track
@export var safety_margin: float = 0.4

# --- Road mesh tuning ---
@export var road_width: float = 12.0         # full width of track
@export var bake_interval: float = 0.4
@export var add_debug_light: bool = true

var _speed: float = 0.0
var _lateral_target: float = 0.0

func _ready() -> void:
	if add_debug_light:
		_ensure_light()

	# Setup PathFollow3D
	follow.loop = true
	follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	follow.h_offset = 0.0
	follow.progress = 0.0

	# Build road mesh
	_build_track_mesh()

	# Start a bit slower
	_speed = target_speed * 0.5

#	if speed_label:
#		speed_label.text = "0 km/h"

func _physics_process(delta: float) -> void:
	# --- Automatic movement ---
	_speed = lerp(_speed, target_speed, 0.5 * delta)

	# Keep car centered on track
	_lateral_target = 0.0
	follow.h_offset = move_toward(follow.h_offset, _lateral_target, lateral_speed * delta)

	# Move along path
	follow.progress += _speed * delta

	# Keep car flat and aligned
	if is_instance_valid(car):
		car.rotation = Vector3.ZERO
		car.translation.y = 0

	# Update HUD
	if speed_label:
		speed_label.text = str(int(_speed * 3.6)) + " km/h"

# --- Helper: ensure there's a directional light ---
func _ensure_light() -> void:
	if not get_node_or_null("DirectionalLight3D"):
		var sun := DirectionalLight3D.new()
		sun.rotation_degrees = Vector3(-60, 30, 0)
		sun.light_energy = 5.0
		add_child(sun)

# --- Build road mesh from Path3D ---
func _build_track_mesh() -> void:
	var c := path.curve
	if c == null:
		push_warning("No curve on TrackPath — cannot build track.")
		return

	c.bake_interval = bake_interval
	var pts: PackedVector3Array = c.get_baked_points()
	if pts.size() < 2:
		push_warning("Curve has too few points to build track.")
		return

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half := road_width * 0.75   # your factor for nicer spacing
	var have_prev := false
	var prev_left := Vector3.ZERO
	var prev_right := Vector3.ZERO

	for i in range(pts.size()):
		var p := pts[i]
		var fwd: Vector3 = ((p - pts[i - 1]).normalized() if i == pts.size() - 1 else (pts[i + 1] - p).normalized())
		var right_vec := fwd.cross(Vector3.UP).normalized()
		var left_edge := p - right_vec * half
		var right_edge := p + right_vec * half

		if have_prev:
			st.set_normal(Vector3.UP); st.set_uv(Vector2(0, i));     st.add_vertex(prev_left)
			st.set_normal(Vector3.UP); st.set_uv(Vector2(1, i));     st.add_vertex(prev_right)
			st.set_normal(Vector3.UP); st.set_uv(Vector2(0, i+1));   st.add_vertex(left_edge)
			st.set_normal(Vector3.UP); st.set_uv(Vector2(1, i));     st.add_vertex(prev_right)
			st.set_normal(Vector3.UP); st.set_uv(Vector2(1, i+1));   st.add_vertex(right_edge)
			st.set_normal(Vector3.UP); st.set_uv(Vector2(0, i+1));   st.add_vertex(left_edge)

		prev_left = left_edge
		prev_right = right_edge
		have_prev = true

	var mesh := st.commit()
	if mesh == null:
		push_warning("Failed to build track mesh.")
		return

	if has_node("RoadMesh"):
		get_node("RoadMesh").queue_free()

	var mi := MeshInstance3D.new()
	mi.name = "RoadMesh"
	mi.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.57, 0.60)
	mat.roughness = 0.6
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = mat

	add_child(mi)
