extends RayCast

export var is_on_floor = true
export var default_surface: String

onready var current_surface: String = default_surface
onready var oscillator: Spatial = $Oscillator
onready var velocity: Spatial = $VelocitySensor

var last_position: Vector3

func _process(delta: float) -> void:
	var ratio = clamp(velocity.meters_per_second / 5, 0, 1)
	
	oscillator.frequency = lerp(1, 3, ratio)
	oscillator.paused = velocity.linear < 0.01

	if is_colliding():
		set_surface_from_collision()
	
func _on_oscillator_peaked(_value: float) -> void:
	if is_on_floor:
		step()
	
func set_surface_from_collision() -> void:
	var groups = get_collider().get_groups()
		
	if !groups.empty():
		# TODO: This is lazy so I don't have to search through all groups. 
		# Update to search through all groups
		var firstGroupName = groups[0]
		current_surface = firstGroupName
			
func step() -> void:
	if !current_surface:
		return
	
	var _sfx = SFX.play_at_location("footsteps/" + current_surface + "_{%n}", global_transform.origin, {
		"pitch_scale": rand_range(1, 1.5)
	})
