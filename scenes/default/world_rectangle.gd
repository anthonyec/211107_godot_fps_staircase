extends Spatial

export var canvas: NodePath
export var temp_is_ready_to_fly: bool = false

onready var tl_corner: Spatial = $TopLeftCorner
onready var tr_corner: Spatial = $TopRightCorner
onready var br_corner: Spatial = $BottomRightCorner
onready var bl_corner: Spatial = $BottomLeftCorner

var canvas_layer: Node2D

func _ready() -> void:
	canvas_layer = get_node_or_null(canvas)

func _process(delta: float) -> void:
	if canvas_layer == null:
		return
		
	var corner_positions: Array = [
		get_viewport().get_camera().unproject_position(tl_corner.global_transform.origin),
		get_viewport().get_camera().unproject_position(tr_corner.global_transform.origin),
		get_viewport().get_camera().unproject_position(br_corner.global_transform.origin),
		get_viewport().get_camera().unproject_position(bl_corner.global_transform.origin)
	]

	for index in len(corner_positions):
		var position = corner_positions[index]
		canvas_layer.get_child(index).position = position

	var top_edge_length = corner_positions[0].distance_to(corner_positions[1])
	var bottom_edge_length = corner_positions[3].distance_to(corner_positions[2])
	var left_edge_length = corner_positions[0].distance_to(corner_positions[3])
	var right_edge_length = corner_positions[1].distance_to(corner_positions[2])
	
	var verticle_edge_percent = clamp(1 - abs(1 - (top_edge_length / bottom_edge_length)), 0, 1)
	var horizontal_edge_percent = clamp(1 - abs(1 - (left_edge_length / right_edge_length)), 0, 1)
	
	var rectangle_percent = (verticle_edge_percent / 2) + (horizontal_edge_percent / 2);
	var is_suitable_rectangle = rectangle_percent > 0.9
	print(is_suitable_rectangle, ", ", rectangle_percent)
	
	temp_is_ready_to_fly = is_suitable_rectangle
