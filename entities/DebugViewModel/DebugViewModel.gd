extends Spatial

signal recoiled

onready var animation: AnimationPlayer = $AnimationPlayer

func point() -> void:
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(global_transform.origin, global_transform.origin + (-global_transform.basis.z) * 1000)
	
	if result:
		print(get_tree().get_root().get_node("Spider"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item"):
		point()
