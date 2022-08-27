extends Node2D

var children = get_children()

func _process(delta: float) -> void:
	update()

func _draw() -> void:
	var color = Color.white if get_parent().get_node("WorldRectangle").temp_is_ready_to_fly else Color.red
	
	for index in get_child_count():
		var current_index = index
		var next_index = index + 1 if index < get_child_count() - 1 else 0
		
		draw_line(get_child(current_index).position, get_child(next_index).position, color)
