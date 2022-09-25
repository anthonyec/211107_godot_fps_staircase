extends Spatial

export var debug: bool = false
export var navigation_node: NodePath

onready var navigation: Navigation = get_node_or_null(navigation_node) as Navigation

var spider: KinematicBody
var current_node_index: int = 0
var path = []

func _ready() -> void:
	spider = get_parent()
	
	if navigation == null:
		print("No navigation node set")
		set_process(false)

func _process(delta: float) -> void:
	for index in range(path.size() - 1):
		var node = path[index]
		
		if debug:
			DebugDraw.draw_box(node, Vector3(0.1, 0.1, 0.1), Color.red)
		
			if index > 0 and path.size() > 2:
				var previous_node = path[index - 1]
				DebugDraw.draw_line_3d(previous_node, node, Color.red)
	
	if !path.empty():
		current_node_index = clamp(current_node_index, 0, path.size() - 1)
			
		var current_node = path[current_node_index] 
		var direction_to_node = global_transform.origin.direction_to(current_node)
		var distance_to_node = global_transform.origin.distance_to(current_node)
		
		if distance_to_node < 0.5:
			current_node_index = current_node_index + 1
			
		if global_transform.origin.distance_to(path[path.size() - 1]) < 0.5:
			current_node_index = 0
			path = []
		
		spider.input_direction = Vector2(direction_to_node.x, direction_to_node.z)
		spider.look_direction = direction_to_node
		
		if debug:
			DebugDraw.draw_ray_3d(global_transform.origin, direction_to_node, 2, Color.red)
	else:
		spider.input_direction = Vector2.ZERO

func _on_debug_cam_select_into_world(position) -> void:
	current_node_index = 0
	path = navigation.get_simple_path(global_transform.origin, position)
