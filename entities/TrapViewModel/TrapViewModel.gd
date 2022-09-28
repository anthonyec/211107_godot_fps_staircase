extends Spatial

signal consumed

var trap = preload("res://entities/Trap/Trap.tscn")

func _process(delta: float) -> void:
	var camera = get_viewport().get_camera()
	var start = camera.global_transform.origin
	var end = camera.global_transform.origin - (camera.global_transform.basis.z * 5)
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(start, end)
	
	if result:
		DebugDraw.draw_box(result.position, Vector3(0.1, 0.1, 0.1), Color.red)
	
	DebugDraw.draw_line_3d(global_transform.origin, end, Color.white)

func place_trap() -> void:	
	var camera = get_viewport().get_camera()
	var start = camera.global_transform.origin
	var end = camera.global_transform.origin - (camera.global_transform.basis.z * 5)
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(start, end)
	
	if result:
		var trap_instance = trap.instance();
		
		get_tree().get_root().add_child(trap_instance)

		trap_instance.global_transform.origin = result.position
		
		SFX.play_at_location("weapons/trap/arm", global_transform.origin)
		emit_signal("consumed")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item"):
		place_trap()
