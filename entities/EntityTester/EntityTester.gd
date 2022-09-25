tool
extends Spatial

export var debug_camera: bool = true
export var show_floor: bool = true

onready var scene_floor: Spatial = $Floor
onready var toggle_slow_motion_buttin: Button = get_node("%ToggleSlowMotionButton")
onready var reset_scene_button: Button = get_node("%ResetSceneButton")

func _ready() -> void:
	if !debug_camera:
		$Camera.queue_free()
	
	scene_floor.visible = show_floor
	
	# Connect buttons
	var _r = reset_scene_button.connect("button_up", self, "reset_scene")
	var _t = toggle_slow_motion_buttin.connect("button_up", self, "toggle_slow_motion")
	
func reset_scene() -> void:
	var _reloaded = get_tree().reload_current_scene()
	
func toggle_slow_motion() -> void:
	if Engine.time_scale == 1:
		Engine.time_scale = 0.1
	else:
		Engine.time_scale = 1
