extends KinematicBody

onready var camera: Camera = $Camera

var walk_speed: float = 2.5
var run_speed: float = 5

var error = 1.1
var gravity = 7
var speed = walk_speed
var mouse_sensitivity: Vector2 = Vector2(20, 30)
var mouse_relative_delta: Vector2
var look_friction = 0.25
var look_velocity: Vector2

var move_friction = 0.08
var move_velocity: Vector3

func _apply_rotation_movement(delta: float) -> void:
	look_velocity += (mouse_relative_delta - look_velocity) * look_friction

	# Left and right. Rotate player, not camera.
	rotation_degrees.y += (-look_velocity.x * mouse_sensitivity.x) * delta

	# Up and down. Only rotate camera.
	camera.rotation_degrees.x += (-look_velocity.y * mouse_sensitivity.y) * delta

	# Clamp up and down looking to floor and sky.
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

	# Reset mouse delta to avoid drift after moving mouse.
	mouse_relative_delta = Vector2.ZERO

func _apply_directional_movement(delta: float) -> void:
	var direction = Vector3.ZERO
	var horizontalAxis = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var verticalAxis = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	var input = Vector2(
		clamp(horizontalAxis * error, -1, 1),
		clamp(verticalAxis * error, -1, 1)
	);

	var input_circle = Vector2(
		input.x * sqrt(1 - input.y * input.y * 0.5),
		input.y * sqrt(1 - input.x * input.x * 0.5)
	)

	direction += Vector3(input_circle.x, 0, input_circle.y) * speed
	move_velocity += (direction - move_velocity) * move_friction

	var forward = global_transform.basis.z
	var right = global_transform.basis.x

	# https://www.gdquest.com/tutorial/godot/2d/top-down-movement/
	var relative_direction = (forward * move_velocity.z + right * move_velocity.x)

	# TODO: Make this work for real with friction and stuff.
	relative_direction.y -= gravity
	
	move_and_slide(relative_direction, Vector3.UP)

func _jump() -> void:
	pass

func _process(delta: float) -> void:
	mouse_relative_delta = mouse_relative_delta + Vector2(
		(Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 8 ,
		(Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 4
	)

	_apply_rotation_movement(delta)
	_apply_directional_movement(delta)


	if Input.is_action_pressed("sprint"):
		speed = run_speed
	else:
		speed = walk_speed

func _input(event):
	if event is InputEventMouseMotion:
		mouse_relative_delta = event.relative

