extends Node2D

var root_position: Vector2 = Vector2(10, 10)
var width = 200
var height = 50
var max_plots = 100
var graphs = {}

func _draw() -> void:
	var graph_index: int = 0;
	
	for name in graphs:
		var graph = graphs[name]
		var previous_position: Vector2 = get_position_from_value(graph, 0, graph.values[0])

		for index in range(graph.values.size() - 1):
			var next_position = get_position_from_value(graph, index, graph.values[index])
			var graph_position = Vector2(0, graph_index * height)
			
			draw_line(
				previous_position + graph_position + root_position,
				next_position + graph_position + root_position, 
				Color.red, 
				2
			)
			
			previous_position = next_position
			
		graph_index = graph_index + 1

func _process(_delta: float) -> void:
	for name in graphs:
		var graph = graphs[name]
		
		if graph.has("values") and graph.values.size() >= max_plots:
			graph.values.remove(0)
	
	update()
	
func get_position_from_value(graph, index, value: float) -> Vector2:
	var min_max_difference = graph.max - graph.min
	var zero_y = height / 2
	var x = (float(index) / max_plots) * width
	var y = zero_y + ((value / min_max_difference) * height)
	
	return Vector2(x, y)

func plot(name: String, value: float) -> void:
	if !graphs.has(name):
		graphs[name] = {
			"values": [],
			"min": 0,
			"max": 1
		}
	
	graphs[name].values.append(value)
	
	if value > graphs[name].max:
		graphs[name].max = value
		
	if value < graphs[name].min:
		graphs[name].min = value
