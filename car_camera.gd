extends Camera3D

@export var target: Node3D               # Player car
@export var distance: float = 8.0        # How far behind the car
@export var height: float = 3.0          # Height above the car
@export var smooth_speed: float = 5.0    # Follow smoothing

var initialized := false                  # First-frame snap

func _process(delta):
	if not target:
		return

	# car faces -Z
	var car_forward = -target.global_transform.basis.z

	# Desired camera position behind and above car
	var desired_position = target.global_transform.origin - car_forward * distance
	desired_position.y += height

	if not initialized:
		# Snap camera behind the car first frame
		global_transform.origin = desired_position
		look_at(target.global_transform.origin, Vector3.UP)
		initialized = true
	else:
		# Smooth follow for subsequent frames
		global_transform.origin = global_transform.origin.lerp(desired_position, smooth_speed * delta)
		look_at(target.global_transform.origin, Vector3.UP)
