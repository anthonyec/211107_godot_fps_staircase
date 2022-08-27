extends RayCast

export var step_size: float = 0.3

onready var foot: MeshInstance = $Foot

var current_foot_position: Vector3
var target_foot_position: Vector3

func _ready() -> void:
	current_foot_position = global_transform.origin - global_transform.basis.y

func _physics_process(delta: float) -> void:
	if is_colliding():
		target_foot_position = get_collision_point()
	else:
		target_foot_position = global_transform.origin - global_transform.basis.y
	
	var distance_to_target = current_foot_position.distance_to(target_foot_position)
	
	if distance_to_target > step_size:
		current_foot_position = target_foot_position

	# Debug foot position
	foot.global_transform.origin = current_foot_position
