extends Spatial

export var iterations = 1;

var bone_length = 1

var target: Position3D
var pole: Position3D
var end_point: Position3D
var bones
var last_target_position: Vector3 

func transform_y(target: Spatial, normal: Vector3) -> void:
	var rotation_axis = Vector3.UP.cross(normal).normalized()
	var rotation_angle = Vector3.UP.angle_to(normal)
	target.transform.basis = Basis(rotation_axis, rotation_angle)

func _ready() -> void:
	target = $Target
	pole = $Pole
	bones = $Chain.get_children()
	end_point = $Chain/Bone1/EndPoint # TODO: Make dynamic or user definable.

func _process(_delta: float) -> void:		
	solve()

func solve() -> void:
#	Vector3 rootPoint = bones[bones.Length - 1].bone.position;
	var root_point = bones[bones.size() - 1].global_transform.origin

	# Point last bone away towards the pole position.
	transform_y(bones[bones.size() - 1], (pole.global_transform.origin - bones[bones.size() - 1].global_transform.origin))
	
	var index = bones.size() - 2

	while index >= 0:
		# Move all bones except the last one to the end of each one (end based on their Y axis).
		bones[index].global_transform.origin = bones[index + 1].global_transform.origin + (bones[index + 1].global_transform.basis.y * bone_length)
		
		# Poiint all bones except the last one towards the pole.
		transform_y(bones[index], (pole.global_transform.origin - bones[index].global_transform.origin))
		index = index - 1


#func stack_bones_based_on_length() -> void:
#	var index = children.size() - 2
#
#	while index >= 0:
#		children[index].global_transform.origin = children[index + 1].global_transform.origin + (-children[index + 1].global_transform.basis.y * bone_length)
#		index = index - 1
#
#func solve() -> void:
#	var root_position: Vector3 = children[children.size() - 1].global_transform.origin
#
#	children[children.size() - 1].look_at(-(pole.global_transform.origin - children[children.size() - 1].global_transform.origin), Vector3.UP)
#
#	stack_bones_based_on_length()
#	return
#
#	for index in range(iterations):
#		children[0].look_at(target.global_transform.origin, Vector3.UP)
#		children[0].global_transform.origin = target.global_transform.origin - (-children[0].global_transform.basis.y * bone_length)
#
#		for j in range(children.size()):
#			children[j].look_at(children[j - 1].global_transform.origin, Vector3.UP)
#			children[j].global_transform.origin = children[j -1].global_transform.origin - (-children[j].global_transform.basis.y * bone_length)
#
#		children[children.size() - 1].global_transform.origin = root_position
#
#		var j = children.size() - 2
#
#		while j >= 0:
#			children[j].global_transform.origin = children[j + 1].global_transform.origin + (-children[j + 1].global_transform.basis.y * bone_length)
#			j = j - 1
#
#		last_target_position = target.global_transform.origin
#
