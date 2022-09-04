extends Spatial

export var start_index: int = 0

var skip_frame: bool = false
var check_index: int = 0

func _ready() -> void:
	check_index = start_index
	
	if get_child_count() != 2:
		set_process(false)

func _process(_delta: float) -> void:
	var leg_to_check = get_child(check_index)
	
	get_child(check_index ^ 1).is_allowed_to_move = false
	leg_to_check.is_allowed_to_move = get_child(check_index ^ 1).state == "plant"
	
	check_index = check_index + 1
	
	if check_index > get_child_count() - 1:
		check_index = 0
