extends Spatial

export var step_size: float = 0.3
export var pole_enabled: bool = true

onready var ik: Spatial = $IK
onready var foot: MeshInstance = $Foot
onready var pole: MeshInstance = $Pole
onready var raycast: RayCast = $RayCast

var current_foot_position: Vector3
var target_foot_position: Vector3
var added_velocity: Vector3 = Vector3.ZERO
var is_allowed_to_take_step: bool = true
var is_taking_step: bool = false

func _ready() -> void:
	current_foot_position = global_transform.origin - global_transform.basis.y
	ik.pole_enabled = pole_enabled
	
func _physics_process(delta: float) -> void:	
	if raycast.is_colliding():
		target_foot_position = raycast.get_collision_point()
	else:
		target_foot_position = global_transform.origin - global_transform.basis.y
	
	var distance_to_target = current_foot_position.distance_to(target_foot_position)
	
	if distance_to_target > step_size and !is_taking_step and is_allowed_to_take_step:
		is_taking_step = true
		var velocity_length = added_velocity.length()
		var clamped_velocity_length = clamp(velocity_length, 0, step_size)
		current_foot_position = target_foot_position + (added_velocity.normalized() * clamped_velocity_length)
		step_taken()	

	# Debug foot position
	foot.global_transform.origin = current_foot_position
	pole.global_transform.origin = current_foot_position + Vector3.UP

func step_taken() -> void:
	is_taking_step = false
	
func set_added_velocity(velocity: Vector3) -> void:
	added_velocity = velocity
