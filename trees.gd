extends Node3D
# Godot 4.5 — fast tree scatter using two MultiMeshes (trunks + crowns)

@export var count: int = 600
@export var area_size: Vector2 = Vector2(300, 300)  # scatter area (X by Z meters)
@export var min_scale: float = 0.8
@export var max_scale: float = 1.4
@export var trunk_height: float = 2.8
@export var crown_radius: float = 1.8
@export var keep_clear_of_track: float = 6.0        # meters; 0 to disable

@export var landscape_path: NodePath = ^"../Landscape"
@export var track_path: NodePath = ^"../TrackPath"

var _land: Node = null
var _curve: Curve3D = null
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_land = get_node_or_null(landscape_path)
	var track := get_node_or_null(track_path) as Path3D
	_curve = track.curve if track else null

	# --- build meshes ---
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.12
	trunk_mesh.bottom_radius = 0.14
	trunk_mesh.height = trunk_height

	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = crown_radius
	crown_mesh.height = crown_radius * 2.0

	# Materials
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.35, 0.20, 0.12) # brown
	trunk_mat.roughness = 1.0

	var crown_mat := StandardMaterial3D.new()
	crown_mat.albedo_color = Color(0.12, 0.55, 0.18) # green
	crown_mat.roughness = 0.8

	# --- create MultiMeshes ---
	var mm_trunk := MultiMesh.new()
	mm_trunk.transform_format = MultiMesh.TRANSFORM_3D
	mm_trunk.mesh = trunk_mesh
	mm_trunk.instance_count = count

	var mm_crown := MultiMesh.new()
	mm_crown.transform_format = MultiMesh.TRANSFORM_3D
	mm_crown.mesh = crown_mesh
	mm_crown.instance_count = count

	# --- host instances ---
	var trunks := MultiMeshInstance3D.new()
	trunks.name = "Trunks"
	trunks.multimesh = mm_trunk
	trunks.material_override = trunk_mat
	add_child(trunks)

	var crowns := MultiMeshInstance3D.new()
	crowns.name = "Crowns"
	crowns.multimesh = mm_crown
	crowns.material_override = crown_mat
	add_child(crowns)

	# --- scatter ---
	var placed := 0
	var tries := 0
	while placed < count and tries < count * 10:
		tries += 1
		var x := _rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var z := _rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)

		# keep away from the road if requested
		if _curve and keep_clear_of_track > 0.0:
			var nearest: Vector3 = _curve.get_closest_point(Vector3(x, 0.0, z))
			var d := Vector2(x, z).distance_to(Vector2(nearest.x, nearest.z))
			if d < keep_clear_of_track:
				continue

		# get ground height from Landscape
		if _land and _land.has_method("get_height_at_world"):
			var y := _land.call("get_height_at_world", x, z) as float

			# random yaw & scale
			var rot := Basis(Vector3.UP, _rng.randf() * TAU)
			var s := _rng.randf_range(min_scale, max_scale)

			# trunk transform (base on ground)
			var t_trunk := Transform3D()
			t_trunk.basis = rot.scaled(Vector3(s, s, s))
			t_trunk.origin = Vector3(x, y + (trunk_height * 0.5) * s, z) # center of cylinder

			# crown transform (sit on top of trunk)
			var t_crown := Transform3D()
			t_crown.basis = rot.scaled(Vector3(s, s, s))
			t_crown.origin = Vector3(x, y + trunk_height * s + crown_radius * s, z)

			mm_trunk.set_instance_transform(placed, t_trunk)
			mm_crown.set_instance_transform(placed, t_crown)
			placed += 1
