extends RayCast

export var is_on_floor = true
export var min_pause_between_steps: float = 300
export var max_pause_between_steps: float = 500
export var default_surface: String
export var volume: float = 3

onready var footstep_sound_left: AudioStreamPlayer3D = $FootstepSoundLeft
onready var footstep_sound_right: AudioStreamPlayer3D = $FootstepSoundRight

onready var current_surface: String = default_surface
var last_position: Vector3
var last_step_time: int
var wait_time: float
var sounds = {}

func scan_directory(path: String, fileNameEndsWith: String = ""):
	var files = []
	var directories = []
	var directory = Directory.new()

	if directory.open(path) == OK:
		directory.list_dir_begin(true, true)

		var file_name = directory.get_next()
		
		while file_name != "":
			if directory.current_is_dir():
				directories.append(file_name)
			else:
				if fileNameEndsWith == "":
					files.append(file_name)
				elif file_name.ends_with(fileNameEndsWith):
						files.append(file_name)
				
			file_name = directory.get_next()
			
	return { "files": files, "directories": directories }

# TODO: Is there a way to build and preload the files and data at build time or import time? This 
# could help with startup performance (not that it's currently bad).
func _ready() -> void:
	footstep_sound_left.max_db = volume
	footstep_sound_right.max_db = volume
	
	var current_directory_path = self.get_script().get_path()
	var base_directory_path = str(current_directory_path).replace("/Footsteps.gd", "/audio/")

	var results = scan_directory(base_directory_path)
	var surfaces = results.directories
	
	for surface in surfaces:
		var surfaceResults = scan_directory(base_directory_path + surface, ".wav")		
		
		for file in surfaceResults.files:
			if !sounds.has(surface):
				sounds[surface] = []

			sounds[surface].append(load(base_directory_path + surface + "/" + file))

func _process(_delta: float) -> void:
	var velocity = global_transform.origin.distance_to(last_position) * 100

	if velocity > 0.1:
		var percent = clamp(1 - (1 / velocity), 0, 10)
		wait_time = lerp(max_pause_between_steps, min_pause_between_steps, percent)

	var time_since_last_step: int = OS.get_ticks_msec() - last_step_time

	if time_since_last_step > wait_time and velocity > 0.1 and is_on_floor:
		step();
		last_step_time = OS.get_ticks_msec()

	last_position = global_transform.origin
	
	if is_colliding():
		var groups = get_collider().get_groups()
		
		if !groups.empty():
			# TODO: This is lazy so I don't have to search through all groups. 
			# Update to search through all groups
			var firstGroupName = groups[0]
			
			if sounds.has(firstGroupName):
				current_surface = firstGroupName
			else:
				current_surface = default_surface


var last_random_index: int = 0
var left_step = true

func get_random_index(size: int) -> int:
	var index = last_random_index

	while index == last_random_index:
		index = floor(rand_range(0, size))

	last_random_index = index

	return index

func step() -> void:
	if !current_surface:
		return
		
	var surface = sounds[current_surface]
	var index = get_random_index(surface.size())
	var footstep_sound: AudioStreamPlayer3D
#
	if left_step:
		footstep_sound = footstep_sound_left
	else:
		footstep_sound = footstep_sound_right
		
	footstep_sound.pitch_scale = rand_range(1, 1.5)
	footstep_sound.stream = surface[index]
	footstep_sound.play()

	left_step = !left_step
