extends Path3D

@export var iterations: int = 2        # around 2 or 3 looks okay; lower = longer straights
@export var track_scale: float = 80.0  # bigger track footprint
@export var height: float = 2.0        # keep car grounded
@export var close_loop: bool = true
@export var padding: float = 5.0       # extra space from world edges

func _ready() -> void:
	var pts2d := _hilbert(iterations)
	var maxn := pow(2, iterations) - 1.0

	var new_curve := Curve3D.new()
	for v in pts2d:
		# scale and center points, add padding
		var x := ((float(v.x) / maxn) - 0.5) * track_scale
		var z := ((float(v.y) / maxn) - 0.5) * track_scale
		new_curve.add_point(Vector3(x, height, z))

	if close_loop and new_curve.point_count > 2:
		new_curve.add_point(new_curve.get_point_position(0))

	self.curve = new_curve

func _hilbert(level: int) -> Array:
	if level <= 1:
		return [Vector2(0,0), Vector2(0,1), Vector2(1,1), Vector2(1,0)]
	var prev := _hilbert(level - 1)
	var size := int(pow(2, level - 1))
	var out: Array = []
	for p in prev: out.append(Vector2(p.y, p.x))
	for p in prev: out.append(Vector2(p.x, p.y + size))
	for p in prev: out.append(Vector2(p.x + size, p.y + size))
	for p in prev: out.append(Vector2(size * 2 - p.y - 1, size - p.x - 1))
	return out
