extends Spatial

export var target_path: NodePath
export var pole_path: NodePath
export var iterations: int = 1;
export var bone_length: float = 1

onready var target: Spatial = get_node(target_path)
onready var pole: Spatial = get_node(pole_path)

var bones
var is_error: bool = false

func transform_y(target: Spatial, normal: Vector3) -> void:
	var rotation_axis = Vector3.UP.cross(normal).normalized()
	var rotation_angle = Vector3.UP.angle_to(normal)
	target.transform.basis = Basis(rotation_axis, rotation_angle)

func _ready() -> void:
	bones = get_children()

func _process(_delta: float) -> void:		
	if is_error:
		return
		
	if !target_path or !pole_path:
		print("IKSolver: No target or pole path set")
		is_error = true
		return
		
	if bones.empty():
		print("IKSolver: No children, no bones!")
		is_error = true
		return
		
	solve()

func solve() -> void:
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
