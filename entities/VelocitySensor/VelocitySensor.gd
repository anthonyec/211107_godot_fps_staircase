extends Spatial

var last_position: Vector3

var linear: float = 0
var direction: Vector3 = Vector3.ZERO
var meters_per_second: float = 0

func _process(delta: float) -> void:
	linear = global_transform.origin.distance_to(last_position)
	direction = last_position.direction_to(global_transform.origin)
	meters_per_second = linear / delta	
	
	last_position = global_transform.origin
