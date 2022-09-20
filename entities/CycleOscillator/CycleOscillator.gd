extends Spatial

signal peaked(wave)

export var paused: bool = false
# Time for one cycle in seconds.
export var frequency: float = 1
export var phase: float = 1

var direction: float = 1
var previous_value: float = 0
var time: float = 0
var tau: float = PI * 2

func _process(delta: float) -> void:
	if paused:
		return
		
	# Cycles and period concept from: https://www.youtube.com/watch?v=fwSWZ-DNm7Y
	var time_in_seconds: float = float(OS.get_ticks_msec()) / 1000
	var cycles: float = time_in_seconds / frequency
	var wave: float = sin((cycles * tau) + phase)

	DebugGraph.plot(wave)
	
	# This is a workaround because the peak never falls exactly on the 
	# amplitude, and I dont know how to fix it.
	# - https://www.reddit.com/r/godot/comments/e05q1l/help_how_to_correctly_set_a_sine_wave_movement/
	if direction == 1 and previous_value > wave:
		direction = -1
		peaked(wave)
		
	if direction == -1 and previous_value < wave:
		direction = 1
		peaked(-wave)
		
	previous_value = wave
	
func peaked(wave: float): 
	emit_signal("peaked", wave)
