class_name Oscillator
extends Spatial

signal peaked(wave)

export var paused: bool = false
export var frequency: float = 1

var phase: float = 0
var direction: float = 1
var previous_value: float = 0
var wave: float = 0

func _process(_delta: float) -> void:
	if paused:
		return
	
	phase = phase + (frequency / 100);
	wave = sin(phase * PI * 2);
	
	# This is a workaround because the peak never falls exactly on the 
	# amplitude, and I dont know how to fix it.
	# - https://www.reddit.com/r/godot/comments/e05q1l/help_how_to_correctly_set_a_sine_wave_movement/
	if direction == 1 and previous_value > wave:
		direction = -1
		peaked(wave)
		
	if direction == -1 and previous_value < wave:
		direction = 1
		peaked(wave)
		
	previous_value = wave
	
func peaked(value: float) -> void: 
	emit_signal("peaked", value)
