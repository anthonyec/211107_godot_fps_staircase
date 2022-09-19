tool
extends Spatial

export var wave_length: float = 1
export var amplitude: float = 1
export var frequency: float = 1
var circumference: float = PI * 2

func _process(delta: float) -> void:
	for index in range(0, 150):
		var z = index / 10
		var y = amplitude * sin(PI * 2 * frequency * s)
		
		DebugDraw.draw_box(Vector3(0, y, -z), Vector3(0.1, 0.1, 0.1), Color.red)
