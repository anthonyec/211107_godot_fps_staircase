extends Spatial

var is_moving: bool = false
var linear: float = 0
var angular: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var meters_per_second: float = 0

var last_position: Vector3
var last_rotation: Vector3

func _process(delta: float) -> void:
	linear = global_transform.origin.distance_to(last_position)
	angular = last_rotation - global_rotation
	direction = last_position.direction_to(global_transform.origin)
	meters_per_second = linear / delta	
	is_moving = linear > 0.005 or angular != Vector3.ZERO
	
	last_rotation = global_rotation
	last_position = global_transform.origin
