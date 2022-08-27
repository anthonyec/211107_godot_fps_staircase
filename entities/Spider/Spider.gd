extends KinematicBody

func _physics_process(delta: float) -> void:
	move_and_slide_with_snap(Vector3(0, 0, 0.1), Vector3.DOWN, Vector3.UP, true)
