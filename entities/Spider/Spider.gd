extends KinematicBody

export var speed: float = 1
export var jump_strength: float = 6
export var gravity: float = 20
export var rotation_speed: float = 2

onready var sphere_cast: Spatial = $SphereCast
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

func _process(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	var velocity = move_and_slide(direction, Vector3.UP, true)
	
	var right = sphere_cast.average_normal.cross(Vector3.UP)
	var forward = -right.cross(sphere_cast.average_normal)
	
	DebugDraw.draw_ray_3d(global_transform.origin, right, 5, Color.green)
	DebugDraw.draw_ray_3d(global_transform.origin, forward, 5, Color.yellow)
	
	for leg_pair in leg_pairs.get_children():
		for leg in leg_pair.get_children():
			leg.added_velocity = velocity
			
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		
		DebugDraw.draw_box(collision.position, Vector3(0.1, 0.1, 0.1), Color.red)
