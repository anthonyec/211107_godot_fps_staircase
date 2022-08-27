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
		
		# Point all bones except the last one towards the pole.
		transform_y(bones[index], (pole.global_transform.origin - bones[index].global_transform.origin))
		index = index - 1
		
	for iteration in range(iterations):
		# Point first bone towards target position.
		transform_y(bones[0], -(target.global_transform.origin - bones[0].global_transform.origin))
		
		# Move first bone to target.
		bones[0].global_transform.origin = target.global_transform.origin - (-bones[0].global_transform.basis.y * bone_length)
		
		# Apply transforms and roations to all other bones except the first.
		var j = 1
		
		while j < bones.size():
			# Point bone towards position between previous and current bone(?).
			transform_y(bones[j], -(bones[j - 1].global_transform.origin - bones[j].global_transform.origin))
			
			# TODO: Explain
			bones[j].global_transform.origin = bones[j - 1].global_transform.origin - (-bones[j].global_transform.basis.y * bone_length)
			j = j + 1
			
		bones[bones.size() - 1].global_transform.origin = root_point
		
		var k = bones.size() - 2

		while k >= 0:
			bones[k].global_transform.origin = bones[k + 1].global_transform.origin + (-bones[k + 1].global_transform.basis.y * bone_length)
			k = k - 1
