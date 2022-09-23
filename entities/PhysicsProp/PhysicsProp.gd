extends RigidBody

export var slide_sfx_name: String = "physics/metal/metal_box_scrape_rough_loop{%n}"
export var soft_impact_sfx_name: String = "physics/metal/metal_box_impact_hard{%n}"
export var hard_impact_sfx_name: String = "physics/metal/metal_box_impact_hard{%n}"

var max_linear_velocity: float = 5
var sliding_ratio_speed: float = 8 # Lower number is a lower speed

var is_moving: bool = false
var is_colliding: bool = false
var is_direct_impact: bool = false
var is_contact_position_different: bool = false
var is_sliding: bool = false
var is_sliding_ratio: float = 0
var contact_local_normal: Vector3 = Vector3.ZERO
var contact_local_position: Vector3 = Vector3.ZERO
var last_contact_local_position: Vector3 = Vector3.ZERO
var last_position: Vector3 = Vector3.ZERO

onready var slide_sfx: AudioStreamPlayer3D = SFX.create(slide_sfx_name, {
	"max_distance": 15,
	"max_db": -15,
	"loop": true
})

func _ready() -> void:
	add_child(slide_sfx)
	slide_sfx.global_transform.origin = global_transform.origin

func _process(delta: float) -> void:
	# Only consider the object is moving after a given velocity threshold to avoid
	# very small velocities counting as movement. Adjust for desired sensitivity.
	is_moving = linear_velocity.length() > 0.01 and global_transform.origin.distance_to(last_position) > 0.001
	
	# Check the similarity between contact normal and velocity direction. If the 
	# similarity is greater than a specfic threshold, count it as a direct hit
	# and not a slide.
	is_direct_impact = abs(
			linear_velocity.normalized().dot(contact_local_normal.normalized())
	) > 0.1
	
	is_sliding = !is_direct_impact and is_moving and is_colliding
	
	# The `is_sliding` boolean can jump between values while the object slides. 
	# To get around this the value is smoothed out by lerping over time.
	is_sliding_ratio = lerp(is_sliding_ratio, (1 if is_sliding else 0), delta * sliding_ratio_speed)
	
	var speed_ratio = clamp((linear_velocity.length() / max_linear_velocity), 0, 1)
	
	slide_sfx.unit_db = lerp(-100, 0, is_sliding_ratio)
	slide_sfx.pitch_scale = lerp(0.9, 1, speed_ratio)
	
	last_contact_local_position = contact_local_position
	last_position = global_transform.origin
		
func _integrate_forces( state ):
	is_colliding = state.get_contact_count() >= 1
	
	if is_colliding:
		contact_local_normal = state.get_contact_local_normal(0)
		
	contact_local_position = state.get_contact_local_position(0)

func _on_body_entered(_body: Node) -> void:
	var impact_ratio = clamp(linear_velocity.length() / max_linear_velocity, 0, 1)
	var soft_hit: bool = impact_ratio < 0.8
	var impact_sfx_name: String = soft_impact_sfx_name if soft_hit else hard_impact_sfx_name
	var max_db: float = -5 if soft_hit else -25
	
	var _sound = SFX.play_at_location(impact_sfx_name, global_transform.origin, {
		"unit_db": lerp(-50, 0, impact_ratio),
		"max_db": max_db,
		"pitch_scale": rand_range(0.9, 1.1)
	})
	
	slide_sfx.play()

func _on_body_exited(_body: Node) -> void:
	pass
