extends Spatial

var legs = []
var stepping_index: int = -1
var average_position: Vector3 = Vector3.ZERO
var average_normal: Vector3 = Vector3.UP

func _ready() -> void:
	legs = get_children()

	for leg in legs:
		leg.connect("on_step", self, "on_step")
	
func _process(_delta: float) -> void:
	var new_average_position: Vector3
	var new_average_normal: Vector3
	
	for leg in legs:
		new_average_position = new_average_position + leg.current_foot_position
		new_average_normal = new_average_normal + leg.current_foot_normal
		
		if stepping_index != -1 and leg.get_index() != stepping_index:
			leg.is_allowed_to_take_step = false
		else:
			leg.is_allowed_to_take_step = true
			
	average_position = new_average_position / legs.size()
	average_normal = new_average_normal / legs.size()
	
	DebugDraw.draw_box(average_position, Vector3(0.2, 0.2, 0.2), Color.red)
	DebugDraw.draw_ray_3d(average_position, average_normal, 1, Color.red)
		
func on_step(index: int) -> void:
	stepping_index = index
	
