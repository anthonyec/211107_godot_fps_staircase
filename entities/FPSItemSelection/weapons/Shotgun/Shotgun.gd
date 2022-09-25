extends Spatial

signal recoiled

func shoot() -> void:
	print("shot")
	SFX.play_at_location("weapons/shotgun/shotgun_fire{%n}", global_transform.origin)
	emit_signal("recoiled")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item"):
		shoot()
