extends Spatial

export var length = 1

var is_colliding = false
var average_normal = Vector3.UP

func _process(delta: float) -> void:
	var normals = []
	
	is_colliding = false
	
	for raycast in get_children():
		if raycast.is_colliding():
			is_colliding = true
			normals.append(raycast.get_collision_normal())
		
	for normal in normals:
		average_normal = ((average_normal + normal) / normals.size()).normalized()
	
	DebugDraw.draw_ray_3d(global_transform.origin, average_normal.normalized(), 2, Color.red)
