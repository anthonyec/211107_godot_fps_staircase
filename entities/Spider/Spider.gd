extends KinematicBody

export var speed: float = 1
export var jump_strength: float = 6
export var gravity: float = 10
export var rotation_speed: float = 2

onready var body: Spatial = $Body

var leg_pairs: Spatial
var snap_vector: Vector3 = Vector3.DOWN
var input_direction: Vector2 = Vector2.ZERO
var look_direction: Vector3 = Vector3.ZERO

func transform_direction_to_camera_angle(direction: Vector3) -> Vector3:
	# Get the active cameras global Y axis rotation and use that to 
	# rotate the direction vector.
	var camera = get_viewport().get_camera()
	var camera_angle_y = camera.global_transform.basis.get_euler().y
	
	return direction.rotated(Vector3.UP, camera_angle_y)
	
func _ready() -> void:
	leg_pairs = get_node("%Legs")

func _process(_delta: float) -> void:
	input_direction = input_direction.normalized()
	
	var direction = Vector3(input_direction.x, 0, input_direction.y)	
	var angle_to_look_direction: float = (-global_transform.basis.z).signed_angle_to(look_direction, global_transform.basis.y)
	
	if abs(angle_to_look_direction) > deg2rad(30):
		direction = Vector3.ZERO
	
	if angle_to_look_direction < deg2rad(-0.5):
		rotate(Vector3.UP, deg2rad(-1))

	if angle_to_look_direction > deg2rad(0.5):
		rotate(Vector3.UP, deg2rad(1))
		
	direction.y = direction.y - gravity
	
	var _velocity = move_and_slide(direction, Vector3.UP, true)
