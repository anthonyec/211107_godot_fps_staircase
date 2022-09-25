class_name SpiderLeg
extends Spatial

export var debug: bool = false
export var move_duration: float = 0.5
export var want_to_step_distance: float = 0.5
export var step_height: float = 0.5

# Height of the foot plant raycast. A value too high will cause the leg to step ontop of high surfaces above the body.
export var leg_height: float = 0.8

# Layer to include in raycast. Found here: https://godotforums.org/d/25733-is-there-a-way-to-tell-the-editor-your-int-is-a-bit-mask-like-collision-mask-or-layer/2
export(int, LAYERS_3D_PHYSICS) var foot_plant_raycast_layer

onready var foot: Spatial = $Foot
onready var pole: Spatial = $Pole
onready var home: Position3D = $Home
onready var velocity: Spatial = $VelocitySensor

var state: String = "plant"
var elapsed_time: float = 0
var plant_foot_position: Vector3 = Vector3.ZERO
var added_velocity: Vector3 = Vector3.ZERO
var is_allowed_to_move: bool = true

# Variables used in states.
var start_foot_position: Vector3 = Vector3.ZERO
var last_position: Vector3 = Vector3.ZERO
var end_position_to_use_as_plant: Vector3 = Vector3.ZERO
var velocity_going_into_move: Vector3 = Vector3.ZERO

func _ready() -> void:
	plant_foot_position = foot.global_transform.origin

func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
		var q0 = p0.linear_interpolate(p1, t)
		var q1 = p1.linear_interpolate(p2, t)
		var r = q0.linear_interpolate(q1, t)
		return r
		
func _process(_delta: float) -> void:	
	if debug:
		DebugDraw.draw_ray_3d(global_transform.origin, added_velocity, added_velocity.length(), Color.red)
		
	if state == "plant":		
		var distance_from_home = plant_foot_position.distance_to(home.global_transform.origin)
		
		foot.global_transform.origin = plant_foot_position
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(plant_foot_position + (Vector3.UP * leg_height), plant_foot_position - (Vector3.UP * leg_height), [], foot_plant_raycast_layer)
		
		if result:
			foot.global_transform.origin = result.position
			
		 # TODO: Add a check for "uncomfortable" positions. Sometimes the spider may stop moving but the leg is stretched too far or overlapping the body or another leg.
		if distance_from_home > want_to_step_distance and is_allowed_to_move and velocity.is_moving:
			state = "start_move"
	
	if state == "start_move":
			start_foot_position = foot.global_transform.origin
			velocity_going_into_move = (velocity.direction * (velocity.meters_per_second * move_duration))
			end_position_to_use_as_plant = home.global_transform.origin + velocity_going_into_move
			
			state = "moving"
			
	if state == "end_move":
			elapsed_time = 0
			plant_foot_position = end_position_to_use_as_plant
			var _sfx = SFX.play_at_location("footsteps/wood_soft_{%n}", global_transform.origin)
			state = "plant"
	
	if state == "moving":
		elapsed_time = elapsed_time + get_process_delta_time();
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(end_position_to_use_as_plant + (Vector3.UP * leg_height), end_position_to_use_as_plant - (Vector3.UP * leg_height), [], foot_plant_raycast_layer)
		
		if result:
			end_position_to_use_as_plant = result.position
			pole.global_transform.origin.y = end_position_to_use_as_plant.y + (leg_height * 2)
				
		var normalized_time = elapsed_time / move_duration
		var end_position = end_position_to_use_as_plant
		var center_point = ((start_foot_position + end_position) / 2) + (Vector3.UP * step_height)
		
		foot.global_transform.origin = quadratic_bezier(start_foot_position, center_point, end_position, normalized_time)

		if debug:
			DebugDraw.draw_box(start_foot_position, Vector3(0.1, 0.1, 0.1), Color.red)
			DebugDraw.draw_box(center_point, Vector3(0.1, 0.1, 0.1), Color.green)
			DebugDraw.draw_box(end_position, Vector3(0.1, 0.1, 0.1), Color.blue)
			
			if result:
				DebugDraw.draw_line_3d(end_position_to_use_as_plant + (Vector3.UP * leg_height), end_position_to_use_as_plant - (Vector3.UP * leg_height), Color.red)
				DebugDraw.draw_box(result.position, Vector3(0.1, 0.1, 0.1), Color.red)
		
		if elapsed_time >= move_duration or foot.global_transform.origin.distance_to(end_position) < 0.005:
			end_position_to_use_as_plant = end_position
			state = "end_move"
