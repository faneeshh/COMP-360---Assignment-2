extends RigidBody3D

# --- Movement tuning ---
@export var move_speed: float = 10.0
@export var turn_speed: float = 2.0
@export var acceleration: float = 5.0       # How quickly the car reaches full speed
@export var spawn_offset: Vector3 = Vector3(1, 2.28, -3)  

# --- HUD ---
@onready var speed_label: Label = $"../UI/SpeedLabel"

# Reference to Path3D
@onready var track_path: Path3D = $"../TrackPath"

var current_speed: float = 0.0  # Track smoothed speed

func _ready():
	if is_instance_valid(track_path) and track_path.curve and track_path.curve.point_count >= 2:
		var start_pos = track_path.curve.get_point_position(0)
		var next_pos = track_path.curve.get_point_position(1)
		var start_dir = (next_pos - start_pos).normalized()
		
		# Apply offsets along track axes
		start_pos += track_path.global_transform.basis.x * spawn_offset.x
		start_pos += track_path.global_transform.basis.z * spawn_offset.z
		start_pos.y = spawn_offset.y

		# Set transform and face along track
		global_transform.origin = start_pos
		look_at(start_pos + start_dir, Vector3.UP)

	gravity_scale = 0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func _physics_process(delta):
	# --- Player input ---
	var forward_input = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var turn_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	# Smooth acceleration / deceleration
	var target_speed = forward_input * move_speed
	current_speed = lerp(current_speed, target_speed, acceleration * delta)

	# Move along local -Z
	if current_speed != 0:
		linear_velocity = -global_transform.basis.z * current_speed
	else:
		linear_velocity = Vector3.ZERO

	# Rotate left/right
	if turn_input != 0:
		rotate_y(-turn_input * turn_speed * delta)

	# Lock Y to track height
	var t = global_transform
	t.origin.y = spawn_offset.y
	global_transform = t

	# --- Update HUD with smoothed speed ---
	if speed_label:
		speed_label.text = str(int(abs(current_speed) * 3.6)) + " km/h"
