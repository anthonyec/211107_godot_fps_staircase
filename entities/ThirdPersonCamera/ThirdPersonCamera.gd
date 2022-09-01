extends Spatial

export var target: NodePath
export var pivot_speed: Vector2
export var distance_from_target: float = 10

onready var pivot = $Pivot
onready var spring_arm: SpringArm = $Pivot/SpringArm
onready var camera: Camera = $Pivot/SpringArm/Camera

var max_fov: float = 90
var min_degrees = deg2rad(20)
var max_degrees = deg2rad(30)
var mouse_sensitivity: float = 5

var original_fov: float
var target_node: Spatial
var mouse_relative_delta: Vector2
var look_friction = 0.25
var look_velocity: Vector2

func _input(event):
	if event is InputEventMouseMotion:
		mouse_relative_delta = event.relative

func _ready() -> void:
	original_fov = camera.fov
	target_node = get_node_or_null(target)
	camera.transform.origin.z = distance_from_target
	spring_arm.spring_length = distance_from_target

func _process(delta: float) -> void:
	if target_node == null:
		return
	
	look_velocity += ((mouse_relative_delta * mouse_sensitivity * delta * Vector2(-1, -1)) - look_velocity) * look_friction
	
	var is_spring_arm_hit = spring_arm.get_hit_length() != spring_arm.spring_length
	var input_direction: Vector2 = Input.get_vector(
		"camera_left", 
		"camera_right", 
		"camera_up", 
		"camera_down"
	) + look_velocity
	var direction = Vector3(input_direction.x, input_direction.y, 0)
	
	rotate_y(direction.x * pivot_speed.x * delta)
	pivot.rotate_x(direction.y * pivot_speed.y * delta)
	pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-85), deg2rad(85))

	# Follow target
	global_transform.origin = target_node.global_transform.origin

	var t = clamp((pivot.rotation.x - min_degrees) / (max_degrees - min_degrees), 0, 1)

	if is_spring_arm_hit:
		camera.fov = lerp(original_fov, max_fov, t)
	
	# Reset mouse delta to avoid drift after moving mouse.
	mouse_relative_delta = Vector2.ZERO
