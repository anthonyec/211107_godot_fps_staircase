extends KinematicBody

export var speed: float = 1
export var jump_strength: float = 6
export var gravity: float = 20
export var rotation_speed: float = 2

onready var sphere_cast: Spatial = $SphereCast
onready var body: Spatial = $Body

var leg_pairs: Spatial
var snap_vector: Vector3 = Vector3.DOWN
var move_velocity: Vector3 = Vector3.ZERO

func transform_direction_to_camera_angle(direction: Vector3) -> Vector3:
	# Get the active cameras global Y axis rotation and use that to 
	# rotate the direction vector.
	var camera = get_viewport().get_camera()
	var camera_angle_y = camera.global_transform.basis.get_euler().y
	return direction.rotated(Vector3.UP, camera_angle_y)
	
func _ready() -> void:
	leg_pairs = get_node("%Legs")

func _physics_process(delta: float) -> void:	
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var rotation_direction: float = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	
	var direction = Vector3.ZERO
	direction += Vector3(input_direction.x, 0, input_direction.y)
	direction = transform_direction_to_camera_angle(direction)

	move_velocity.x = direction.x * speed
	move_velocity.z = direction.z * speed
	
#	if sphere_cast.is_colliding:
#		move_velocity -= sphere_cast.average_normal * gravity * 2 * delta
#	else:
#		print("OH")
	move_velocity.y -= gravity * delta

	var just_landed = is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping = is_on_floor() and Input.is_action_just_pressed("jump")

	if is_jumping:
		move_velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN

	rotate(Vector3.UP, deg2rad(-rotation_direction * rotation_speed))
	move_velocity = move_and_slide_with_snap(move_velocity, snap_vector, Vector3.UP, true)
	
	var move_velocity_without_gravity = Vector3(move_velocity.x, 0, move_velocity.z)
	
	for leg_pair in leg_pairs.get_children():
		for leg in leg_pair.get_children():
			leg.added_velocity = move_velocity_without_gravity
			
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		
		DebugDraw.draw_box(collision.position, Vector3(0.1, 0.1, 0.1), Color.red)
#		print(collision.collider.name)
