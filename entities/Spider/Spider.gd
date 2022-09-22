extends KinematicBody

export var speed: float = 1
export var jump_strength: float = 6
export var gravity: float = 10
export var rotation_speed: float = 2

onready var body: Spatial = $Body

var leg_pairs: Spatial
var snap_vector: Vector3 = Vector3.DOWN

func transform_direction_to_camera_angle(direction: Vector3) -> Vector3:
	# Get the active cameras global Y axis rotation and use that to 
	# rotate the direction vector.
	var camera = get_viewport().get_camera()
	var camera_angle_y = camera.global_transform.basis.get_euler().y
	return direction.rotated(Vector3.UP, camera_angle_y)
	
func _ready() -> void:
	leg_pairs = get_node("%Legs")

func _process(_delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	
	direction.y = direction.y - gravity
	direction = direction.rotated(Vector3.UP, global_transform.basis.get_euler().y)
	
	if Input.is_action_pressed("jump"):
		direction.y = direction.y + 100
		
	if Input.is_action_pressed("rotate_left"):
		rotate(Vector3.UP, deg2rad(1))
		
	if Input.is_action_pressed("rotate_right"):
		rotate(Vector3.UP, deg2rad(-1))
	
	var _velocity = move_and_slide(direction, Vector3.UP, true)
