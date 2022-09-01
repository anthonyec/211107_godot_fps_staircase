extends Spatial

onready var joint1: Spatial = $Joint1
onready var joint2: Spatial = $Joint2
onready var joint3: Spatial = $Joint3

func _process(_delta: float) -> void:
	var direction = joint1.global_transform.origin.direction_to(joint3.global_transform.origin)
	var right = direction.cross(Vector3.UP).normalized()
	var up = direction.cross(right).normalized()
	var plane = Plane(
		joint1.global_transform.origin + right,
		joint1.global_transform.origin - right,
		joint1.global_transform.origin + up
	)
	
	var projected_position = plane.project(joint2.global_transform.origin)
	
	DebugDraw.draw_box(plane.center(), Vector3(0.1, 0.1, 0.1), Color.black)
	DebugDraw.draw_ray_3d(plane.center(), plane.normal, 1, Color.black)	
	DebugDraw.draw_box(projected_position, Vector3(0.1, 0.1, 0.1), Color.red)
	
	pass
