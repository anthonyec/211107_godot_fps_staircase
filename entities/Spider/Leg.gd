extends Spatial

signal on_step(index)

export var step_size: float = 0.3
export var step_height: float = 0.2
export var pole_enabled: bool = true

onready var ik: Spatial = $IK
onready var foot: MeshInstance = $Foot
onready var pole: MeshInstance = $Pole
onready var raycast: RayCast = $RayCast

var current_foot_position: Vector3 = Vector3.ZERO
var target_foot_position: Vector3 = Vector3.ZERO
var added_velocity: Vector3 = Vector3.ZERO
var is_allowed_to_take_step: bool = true
var is_taking_step: bool = false
var time_since_step_taken = 0

func _ready() -> void:
	current_foot_position = raycast.global_transform.origin - raycast.global_transform.basis.y
	ik.pole_enabled = pole_enabled
	
func _physics_process(_delta: float) -> void:
	if raycast.is_colliding():
		target_foot_position = raycast.get_collision_point()
	else:
		target_foot_position = global_transform.origin - global_transform.basis.y
	
	var distance_to_target = current_foot_position.distance_to(target_foot_position)
	var time_difference = OS.get_ticks_msec() - time_since_step_taken;
	
	if distance_to_target > step_size and !is_taking_step and time_difference > 250 and is_allowed_to_take_step:
		emit_signal("on_step", get_index())
		is_taking_step = true
		
		var velocity_length = added_velocity.length()
		var clamped_velocity_length = clamp(velocity_length, 0, step_size)
		var target = target_foot_position + (added_velocity.normalized() * clamped_velocity_length)
		
		var tween = create_tween()
		tween.tween_property(foot, "global_translation", foot.global_transform.origin + (foot.global_transform.origin.direction_to(target) * 0.5) + (Vector3.UP * step_height), 0.1)
		tween.chain().tween_property(foot, "global_translation", target, 0.1)
		tween.connect("finished", self, "step_taken")
	
	if !is_taking_step:
		foot.global_transform.origin = current_foot_position
		
	pole.global_transform.origin = foot.global_transform.origin + Vector3.UP


func step_taken() -> void:
	current_foot_position = foot.global_transform.origin
	is_taking_step = false
	time_since_step_taken = OS.get_ticks_msec()
	emit_signal("on_step", -1)
	
func set_added_velocity(velocity: Vector3) -> void:
	added_velocity = velocity
