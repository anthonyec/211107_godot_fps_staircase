tool
extends MeshInstance

export var target: NodePath

var target_object: Position3D

func _process(delta: float) -> void:
	target_object = get_node_or_null(target)
	
	if !target_object:
		print("No target object")
		return
		
	look_at(target_object.global_transform.origin, Vector3.FORWARD)
	
#	global_transform.basis.y = global_transform.origin - target_object.global_transform.origin
	
#	global_scale(Vector3(1, 1, 1))
