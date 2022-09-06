extends AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		playback_active = !playback_active
		
	if event.is_action_pressed("ui_right"):
		advance(0.05)
		
	if event.is_action_pressed("ui_left"):
		advance(-0.05)
		
	if event.is_action_pressed("ui_up"):
		playback_speed = playback_speed + 0.1

	if event.is_action_pressed("ui_down"):
		playback_speed = playback_speed - 0.1
