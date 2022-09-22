extends RigidBody

var max_linear_velocity: float = 10
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

onready var slide_sfx: AudioStreamPlayer3D = SFX.create("physics/metal/metal_box_scrape_rough_loop{%n}", {
	"loop": true
})

func _ready() -> void:
	slide_sfx.global_transform.origin = global_transform.origin
	add_child(slide_sfx)

func _process(delta: float) -> void:
	DebugDraw.draw_ray_3d(global_transform.origin, linear_velocity.normalized(), linear_velocity.length(), Color.darkgreen)
	DebugDraw.draw_ray_3d(global_transform.origin, contact_local_normal, 3, Color.blue)
	
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
		
	slide_sfx.unit_db = lerp(-50, 10, is_sliding_ratio)
	
	last_contact_local_position = contact_local_position
	last_position = global_transform.origin
		
func _integrate_forces( state ):
	is_colliding = state.get_contact_count() >= 1
	
	if is_colliding:
		contact_local_normal = state.get_contact_local_normal(0)
		
	contact_local_position = state.get_contact_local_position(0)

func _on_body_entered(_body: Node) -> void:
	var impact_ratio = clamp(linear_velocity.length() / max_linear_velocity, 0, 1)
	var _sound = SFX.play_at_location("physics/metal/metal_box_impact_hard{%n}", global_transform.origin, {
		"unit_db": lerp(-10, 20, impact_ratio)
	})
	
	slide_sfx.play()
	DebugDraw.draw_ray_3d(global_transform.origin, contact_local_normal, 3, Color.blue)

func _on_body_exited(_body: Node) -> void:
	pass
