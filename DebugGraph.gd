extends Node2D

var width = 200
var height = 100
var max_plots = 50
var graph = []

var max_value: float = 1
var min_value: float = 0

func _draw() -> void:
	var previous_position: Vector2 = get_position_from_value(0, graph[0])
	
	for index in range(graph.size() - 1):
		var next_position = get_position_from_value(index, graph[index])
		
		draw_line(previous_position, next_position, Color.red, 2)
		
		previous_position = next_position

func _process(_delta: float) -> void:
	if graph.size() >= max_plots:
		graph.remove(0)

	update()
	
func get_position_from_value(index: int, value: float) -> Vector2:
	var min_max_difference = max_value - min_value
	var zero_y = height / 2
	var x = (float(index) / max_plots) * width
	var y = zero_y + ((value / min_max_difference) * height)
	
	return Vector2(x, y)

func plot(value: float) -> void:
	graph.append(value)
	
	if value > max_value:
		max_value = value
		
	if value < min_value:
		min_value = value
