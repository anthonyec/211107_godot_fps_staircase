extends KinematicBody

export var enabled: bool = true
export var walk_speed: float = 2
export var run_speed: float = 4
export var jump_strength: float = 6
export var gravity: float = 20
export var look_sensitivity: Vector2 = Vector2(15, 20)
export var head_bob: Vector2 = Vector2(0, 0.06)
var input_friction = 0.2
var look_friction = 0.5

onready var head: Spatial = $Head
onready var footsteps: = $Footsteps
onready var camera: Camera = get_node("%Camera")
onready var item_selection: Spatial = get_node("%FPSItemSelection") # TODO: Rename.
onready var velocity: Spatial = $VelocitySensor

var is_running: bool = false
var snap_vector: Vector3 = Vector3.DOWN
var move_velocity: Vector3 = Vector3.ZERO
var input_velocity: Vector3 = Vector3.ZERO
var look_velocity: Vector2
var mouse_relative_delta: Vector2
var rotation_bob_ratio: float = 0

var original_head_position: Vector3
var original_item_selection_position: Vector3

func _ready() -> void:
	original_head_position = head.transform.origin
	original_item_selection_position = item_selection.transform.origin

func _physics_process(delta: float) -> void:
	var speed: float = run_speed if is_running else walk_speed
	var just_landed = is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping = is_on_floor() and Input.is_action_just_pressed("jump")
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3.ZERO
	
	direction += Vector3(input_direction.x, 0, input_direction.y)
	input_velocity += (direction - input_velocity) * input_friction

	move_velocity.x = input_velocity.x * speed
	move_velocity.z = input_velocity.z * speed
	move_velocity.y -= gravity * delta
	move_velocity = move_velocity.rotated(Vector3.UP, rotation.y)

	if is_jumping:
		move_velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
		var _sfx = SFX.play_at_location("footsteps/wood_hard_{%n}", global_transform.origin)

	move_velocity = move_and_slide_with_snap(move_velocity, snap_vector, Vector3.UP, true)
	apply_rotation(delta)
	footsteps.is_on_floor = is_on_floor()

	rotation_bob_ratio = lerp(rotation_bob_ratio, clamp(velocity.meters_per_second / run_speed, 0, 1), delta * 1.5)
	var head_bob_position = original_head_position + (Vector3.UP * head_bob.y * abs(footsteps.oscillator.wave))	
	
	head.transform.origin = original_head_position.linear_interpolate(head_bob_position, rotation_bob_ratio)
	head.rotation.z = deg2rad(lerp(0, footsteps.oscillator.wave, rotation_bob_ratio))
	
	item_selection.transform.origin = original_item_selection_position.linear_interpolate(
		original_item_selection_position + (Vector3.UP * footsteps.oscillator.wave * 0.01), 
		rotation_bob_ratio
	)	
	item_selection.rotation.y = deg2rad(lerp(0, footsteps.oscillator.wave * 4, rotation_bob_ratio))

func _process(_delta: float) -> void:
	is_running = Input.is_action_pressed("sprint")
	
func apply_rotation(delta: float) -> void:
	mouse_relative_delta = mouse_relative_delta + Vector2(
		(Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 10 ,
		(Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 8
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


