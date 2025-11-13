extends RigidBody3D

func _ready():
	# Raise car above track
	var t = global_transform
	t.origin.y = 2
	global_transform = t

	# Temporarily disable gravity
	gravity_scale = 0
