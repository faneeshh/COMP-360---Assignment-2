extends Node3D
#had to turn off collisions because when the cars bumped together it was a disaster and I didnt know how to fix their course 
func _ready():
	var col = $CollisionShape3D
	if col:
		col.disabled = true
