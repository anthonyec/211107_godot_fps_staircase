extends Spatial

onready var item_selection: Spatial = $EntityTesterScene/FPSItemSelection

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		item_selection.previous_item()
		
	if event.is_action_pressed("ui_right"):
		item_selection.next_item()
		
	if event.is_action_pressed("ui_select"):
		item_selection.use_current_item()
