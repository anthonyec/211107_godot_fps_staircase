extends Spatial

export var debug: bool = false
export var start_index: int = 0
export var frequency: float = 5

onready var oscillator: Spatial = $Oscillator

var active_leg_index: int = 0
var legs = []

func _ready() -> void:
	active_leg_index = start_index
	
	oscillator.frequency = frequency
	
	for child in get_children():
		if !(child as Oscillator) and (child as SpiderLeg):
			legs.append(child)
	
	if legs.size() == 0:
		print("No legs found as children. Make sure legs have a class_name of 'SpiderLeg' and are direct children of a LegPair.")
		set_process(false)

func _process(_delta: float) -> void:
	var target_leg = legs[active_leg_index]	
	var other_leg = legs[active_leg_index ^ 1]
	
	other_leg.is_allowed_to_move = false
	target_leg.is_allowed_to_move = other_leg.state == "plant"
	
	if debug:
		DebugGraph.plot("leg_frequency_" + String(get_instance_id()), oscillator.wave)
		
		if target_leg.is_allowed_to_move:
			DebugDraw.draw_box(target_leg.global_transform.origin, Vector3(0.1, 0.1, 0.1), Color.red)

func _on_oscillator_peaked(_wave: float) -> void:
	if active_leg_index == 0:
		active_leg_index = 1
	else:
		active_leg_index = 0
	
