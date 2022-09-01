extends KinematicBody

export var enabled: bool = true
export var speed: float = 5
export var jump_strength: float = 6
export var gravity: float = 20
export var look_sensitivity: Vector2 = Vector2(15, 20)
var input_friction = 0.2
var look_friction = 0.5

onready var camera: Camera = $Camera
onready var footsteps: = $Footsteps

var snap_vector: Vector3 = Vector3.DOWN
var move_velocity: Vector3 = Vector3.ZERO
var input_velocity: Vector3 = Vector3.ZERO
var look_velocity: Vector2
var mouse_relative_delta: Vector2

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_direction: Vector3 = Vector3(input_direction.x, 0, input_direction.y)
	
	var direction = Vector3.ZERO
	direction += Vector3(input_direction.x, 0, input_direction.y)
	input_velocity += (direction - input_velocity) * input_friction

	move_velocity.x = input_velocity.x * speed
	move_velocity.z = input_velocity.z * speed
	move_velocity.y -= gravity * delta
	move_velocity = move_velocity.rotated(Vector3.UP, rotation.y)

	var just_landed = is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping = is_on_floor() and Input.is_action_just_pressed("jump")

	if is_jumping:
		move_velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN

	move_velocity = move_and_slide_with_snap(move_velocity, snap_vector, Vector3.UP, true)
	apply_rotation(delta)
	
	footsteps.is_on_floor = is_on_floor()
	
func apply_rotation(delta: float) -> void:
	mouse_relative_delta = mouse_relative_delta + Vector2(
		(Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 8 ,
		(Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 4
	)

	look_velocity += (mouse_relative_delta - look_velocity) * look_friction

	# Left and right. Rotate player, not camera.
	rotation_degrees.y += (-look_velocity.x * look_sensitivity.x) * delta

	# Up and down. Only rotate camera.
	camera.rotation_degrees.x += (-look_velocity.y * look_sensitivity.y) * delta

	# Clamp up and down looking to floor and sky.
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

	# Reset mouse delta to avoid drift after moving mouse.
	mouse_relative_delta = Vector2.ZERO

func apply_movement() -> void:
	pass
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_relative_delta = event.relative


