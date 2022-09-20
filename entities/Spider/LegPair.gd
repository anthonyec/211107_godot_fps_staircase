extends Spatial

export var start_index: int = 0

onready var oscillator: Spatial = $Oscillator

var active_leg_index: int = 0
var legs = []

func _ready() -> void:
	active_leg_index = start_index
	
	oscillator.frequency = 5
	
	for child in get_children():
		if !(child as Oscillator) and (child as SpiderLeg):
			legs.append(child)


func _process(_delta: float) -> void:
	var target_leg = legs[active_leg_index]	
	var other_leg = legs[active_leg_index ^ 1]
	
	other_leg.is_allowed_to_move = false
	target_leg.is_allowed_to_move = other_leg.state == "plant"

func _on_oscillator_peaked(_wave: float) -> void:
	if active_leg_index == 0:
		active_leg_index = 1
	else:
		active_leg_index = 0
