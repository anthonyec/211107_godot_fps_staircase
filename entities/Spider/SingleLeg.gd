class_name SpiderLeg
extends Spatial

export var debug: bool = false
export var move_duration: float = 0.5
export var want_to_step_distance: float = 0.2
export var step_height: float = 0.6

onready var foot: Spatial = $Foot
onready var home: Position3D = $Home
onready var homeRaycast: RayCast = $HomeRayCast

var state: String = "plant"
var elapsed_time: float = 0
var plant_foot_position: Vector3 = Vector3.ZERO
var added_velocity: Vector3 = Vector3.ZERO
var is_allowed_to_move: bool = true
var local_original_home_raycast_position: Vector3 = Vector3.ZERO

# Variables used in states.
var start_foot_position: Vector3 = Vector3.ZERO
var last_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	local_original_home_raycast_position = homeRaycast.transform.origin
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
		
		if distance_from_home > want_to_step_distance and is_allowed_to_move:
			state = "start_move"
	
	if state == "start_move":
			start_foot_position = foot.global_transform.origin
			state = "moving"
			
	if state == "end_move":
			elapsed_time = 0
			plant_foot_position = homeRaycast.get_collision_point()
			homeRaycast.transform.origin = local_original_home_raycast_position
			state = "plant"
	
	if state == "moving":
		elapsed_time = elapsed_time + get_process_delta_time();
		
		var normalized_time = elapsed_time / move_duration
		var end_position = homeRaycast.get_collision_point()
		var center_point = ((start_foot_position + end_position) / 2) + (Vector3.UP * step_height)
		
		foot.global_transform.origin = quadratic_bezier(start_foot_position, center_point, end_position, normalized_time)
		
		if debug:
			DebugDraw.draw_box(start_foot_position, Vector3(0.1, 0.1, 0.1), Color.red)
			DebugDraw.draw_box(center_point, Vector3(0.1, 0.1, 0.1), Color.green)
			DebugDraw.draw_box(end_position, Vector3(0.1, 0.1, 0.1), Color.blue)
		
		if elapsed_time >= move_duration or foot.global_transform.origin.distance_to(end_position) < 0.08:
			state = "end_move"
