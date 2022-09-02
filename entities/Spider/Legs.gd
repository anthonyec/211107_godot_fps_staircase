extends Spatial

var legs = []
var stepping_index: int = -1

func _ready() -> void:
	legs = get_children()

	for leg in legs:
		leg.connect("on_step", self, "on_step")
	
func _process(_delta: float) -> void:
	for leg in legs:
		if stepping_index != -1 and leg.get_index() != stepping_index:
			leg.is_allowed_to_take_step = false
		else:
			leg.is_allowed_to_take_step = true
		
func on_step(index: int) -> void:
	stepping_index = index
	
