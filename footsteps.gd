extends RayCast

onready var footstep_sound: AudioStreamPlayer3D = $FootstepSound

var wood_1 = [
	preload("res://footsteps/wood_1_footstep_1.wav"),
	preload("res://footsteps/wood_1_footstep_2.wav"),
	preload("res://footsteps/wood_1_footstep_3.wav")
]

var wood_2 = [
	preload("res://footsteps/wood_2_footstep_1.wav"),
	preload("res://footsteps/wood_2_footstep_2.wav"),
	preload("res://footsteps/wood_2_footstep_3.wav"),
	preload("res://footsteps/wood_2_footstep_4.wav"),
	preload("res://footsteps/wood_2_footstep_5.wav")
]

var dirt_1 = [
	preload("res://footsteps/dirt_1_footstep_1.wav"),
	preload("res://footsteps/dirt_1_footstep_2.wav"),
	preload("res://footsteps/dirt_1_footstep_3.wav"),
	preload("res://footsteps/dirt_1_footstep_4.wav")
]

var water_1 = [
	preload("res://footsteps/water_1_footstep_1.wav"),
	preload("res://footsteps/water_1_footstep_2.wav"),
	preload("res://footsteps/water_1_footstep_3.wav"),
	preload("res://footsteps/water_1_footstep_4.wav")
]

var current_material = wood_2

var last_position: Vector3
var last_step_time: int = 0
var wait_time: float = 1000

var min_pause_between_steps: float = 200
var max_pause_between_steps: float = 700

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var velocity = global_transform.origin.distance_to(last_position) * 100
	var steps_per_second = 1;
	
	if velocity > 0.1:
		var percent = clamp(1 - (1 / velocity), 0, 10)
		wait_time = lerp(max_pause_between_steps, min_pause_between_steps, percent)
	else:
		# Ensures a step is taken when start walking, undecided if should be kept.
		last_step_time = 0

	var time_since_last_step: int = OS.get_ticks_msec() - last_step_time
	
	if time_since_last_step > wait_time and velocity > 0.1 and get_parent().is_on_floor():
		_step();
		last_step_time = OS.get_ticks_msec()

	last_position = global_transform.origin
	
	if is_colliding():
		if get_collider().is_in_group('dirt_1'):
			current_material = dirt_1
		elif get_collider().is_in_group('wood_1'):
			current_material = wood_1
		elif get_collider().is_in_group('water_1'):
			current_material = water_1
		else:
			current_material = wood_2

var last_random_index: int = 0

func _get_random_index(size: int) -> int:
	var index = last_random_index

	while index == last_random_index:
		index = floor(rand_range(0, size))
	
	last_random_index = index
	
	return index
	
func _step() -> void:
	var index = _get_random_index(current_material.size())
	
	footstep_sound.pitch_scale = rand_range(1, 1.5)
	footstep_sound.stream = current_material[index]
	footstep_sound.play()
