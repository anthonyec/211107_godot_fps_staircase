extends Node

func _ready() -> void:
	
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var _sfx = SFX.play_everywhere("warning", {
			"volume_db": -20
		})
		get_tree().paused = !get_tree().paused
		
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
