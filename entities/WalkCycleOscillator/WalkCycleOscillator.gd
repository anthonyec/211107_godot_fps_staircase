extends Spatial

signal peaked(value)

export var paused: bool = false
export var frequency: float = 0.05
export var amplitude: float = 1
export var offset: float = 0

var value: float = 0
var previous_value: float = 0
var direction: int = 1

func _process(delta: float) -> void:
	if paused:
		return
		
	var time = OS.get_ticks_msec()
	
	value = amplitude * sin((frequency * time) + offset)
#	value = value * delta
	
	# TODO: Multiplying by delta may not be needed here. Suposed to make it FPS independent.
	
	# This is a workaround because the peak never falls exactly on the 
	# amplitude, and I dont know how to fix it.
	# - https://www.reddit.com/r/godot/comments/e05q1l/help_how_to_correctly_set_a_sine_wave_movement/
	if direction == 1 and previous_value > value:
		direction = -1
		emit_signal("peaked", amplitude)
		
	if direction == -1 and previous_value < value:
		direction = 1
		emit_signal("peaked", -amplitude)

func reset_value() -> void:
	value = 0
