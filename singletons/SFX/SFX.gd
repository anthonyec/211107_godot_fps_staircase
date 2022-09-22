extends Spatial

var loaded: bool = false
# Type of sounds variable is: "sound_name": ["sound_file.wav": AudioStream]
var sounds = {}

func _ready():
	print("SFX: Started")
	
	var current_directory_path = self.get_script().get_path()
	var base_directory_path = str(current_directory_path).replace("/SFX.gd", "/audio")
	var results = scan_directory(base_directory_path, ".wav")
	
	for result in results:
		# Remove the leading "/" and remove the trailing file extension including period.
		# E.g, the path "/physics/glass/sound.wav" will become "physics/glass/sound"
		var name = result.replace(base_directory_path, "").trim_prefix("/").replace(result.get_extension(), "").trim_suffix(".")
		
		# TODO: This is a lazy way to get the number at the end. The correct way would be to use
		# regex or going backwards of each char.
		var number = name.to_int()
		var name_without_number_suffix = name.replace(number, "")
		
		sounds[name] = [load(result)]
		
		# TODO: This does not supprt the number "0".
		if number != 0:
			if !sounds.has(name_without_number_suffix):
				sounds[name_without_number_suffix] = []
		
			sounds[name_without_number_suffix].append(load(result))
	
	loaded = true

func play_at_location(name: String, position: Vector3, options = {}) -> AudioStreamPlayer3D:
	if !sounds.has(name.trim_suffix("{%n}")):
		print("SFX: The sound called '", name, "' does not exist.")
		return AudioStreamPlayer3D.new()
		
	var file = null
	
	if name.ends_with("{%n}"):
		var name_without_template = name.trim_suffix("{%n}")
		var number_of_sound_files = sounds[name_without_template].size()
		var random_index = floor(rand_range(0, number_of_sound_files))

		file = sounds[name_without_template][random_index]
	else:
		file = sounds[name][0]
		
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	var timer: SceneTreeTimer = get_tree().create_timer(float(file.get_length()), false)
	
	player.attenuation_filter_cutoff_hz = 20500
	player.stream = file
	player.unit_db = 0
	
	if options.has("unit_db"):
		player.unit_db = options["unit_db"]
	
	var _signal = timer.connect("timeout", player, "queue_free")
	add_child(player)
	
	player.global_transform.origin = position
	player.play()
	
	return player

func scan_directory(path: String, fileNameEndsWith: String = ""):
	var results = []
	var directory = Directory.new()

	if directory.open(path) == OK:
		directory.list_dir_begin(true, true)

		var file_name = directory.get_next()
		
		while file_name != "":
			if directory.current_is_dir():
				var directory_path_to_scan = path + "/" + file_name
				var recursive_results = scan_directory(directory_path_to_scan, fileNameEndsWith)
				results.append_array(recursive_results)
			else:
				if fileNameEndsWith == "":
					results.append(path + "/" + file_name)
				elif file_name.ends_with(fileNameEndsWith):
					results.append(path + "/" + file_name)
				
			file_name = directory.get_next()
			
	return results
