tool
extends Spatial

export var editor: bool = false
export var debug: bool = false
export(Array, NodePath) var selected_bones = []
export var target_path: NodePath
export var pole_path: NodePath
export var iterations: int = 10;
export var pole_enabled: bool = false

onready var target: Spatial = get_node(target_path)
onready var pole: Spatial = get_node(pole_path)

var tolerance: float = 0.002

var bones = []
var positions = []
var lengths = []
var total_length: float = 0
var allow_reach: bool = false

func _ready() -> void:
	if selected_bones.empty():
		bones = get_children()
	else:
		for selected_bone in selected_bones:
			bones.append(get_node(selected_bone.get_as_property_path()))

	if is_error():
		set_process(false)
		return
	
	for index in range(bones.size()):
		var bone = bones[index]
		
		positions.append(bone.global_transform.origin)

		if index > 0:
			var distance = bones[index - 1].global_transform.origin.distance_to(bones[index].global_transform.origin)
			
			total_length = total_length + distance
			lengths.append(distance)

func _process(_delta: float) -> void:	
	if !editor and Engine.is_editor_hint():
		return
		
	solve()

func is_error() -> bool:
	if bones.empty():
		print("IK: No children, no bones!")
		return true
		
	if !target_path:
		print("IK: No target path set")
		return true
		
	if pole_enabled and !pole_path:
		print("IK: No pole path set")
		return true
		
	return false

func solve() -> void:	
	# Get positions of all bones.
	for index in range(bones.size()):
		positions[index] = bones[index].global_transform.origin
	
	var last_leaf_position = positions[positions.size() - 1]
	
	# If the target distance is greater than the total length then move all
	# bones towards the target except the first bone.
	## TODO: Work out why this is so snappy! Need to use distance_error to reduce snappy-ness
	if allow_reach and positions[0].distance_to(target.global_transform.origin) >= total_length:
		var direction = positions[0].direction_to(target.global_transform.origin)

		for index in range(1, positions.size()):
			positions[index] = positions[index - 1] + (direction * lengths[index - 1])
			
	else:
		# TODO: Explain why pole is done before solve iterations.
		if pole_enabled:
			# Pull all joints except the root and lead slightly towards the pole position before solving. 
			# It's a naive solution to ensure the IK chain bends towards the pole. Inspired by:
			# - https://gamedev.stackexchange.com/a/163474
			# - https://github.com/jsantell/THREE.IK/issues/3#issuecomment-385537004
			for index in range(positions.size() - 2):
				var next_index = index + 1
				var length = lengths[index]
				var difference_between_bone_and_pole = pole.global_transform.origin - positions[next_index]
				var clamped_distance_between_bone_and_pole = clamp(difference_between_bone_and_pole.length(), 0, length)
				
				# TODO: Explain why it's like this.					
				positions[next_index] = positions[next_index] + (difference_between_bone_and_pole.normalized() * clamped_distance_between_bone_and_pole)
		
		for _iteration in range(iterations):				
			# Go back through the chain, from leaf to root, to calculate the positions.
			# Move the leaf bone to the target position.
			positions[positions.size() - 1] = target.global_transform.origin
			
			for index in range(1, positions.size()):
				# Get the reverse index as if we are going backgrounds (godot doesn't have reverse for loops).
				var current_index = positions.size() - index
				var next_index = current_index - 1
				var direction = positions[current_index].direction_to(positions[next_index])
				var length = lengths[next_index]
				
				positions[next_index] = positions[current_index] + direction * length
				
				# If the chain is a straight line (collinear) and the target is located on that line, then 
				# the algorithm fails to bend the chain. Apparently This is a common problem of IK solvers 
				# and the work around is random perturbation of a joint positions in the backwards phase.
				# See: 3.3 of "Extending FABRIK with model constraints":
				# - http://andreasaristidou.com/publications/papers/Extending_FABRIK_with_Model_C%CE%BFnstraints.pdf
				# TODO: CHange this if statement to a real collinear check: https://math.stackexchange.com/a/635898
				if direction == Vector3.RIGHT or direction == Vector3.LEFT or direction == Vector3.UP or direction == Vector3.DOWN or direction == Vector3.FORWARD or direction == Vector3.BACK:
					positions[next_index]  = positions[next_index] + Vector3(rand_range(-0.01, 0.01), rand_range(-0.01, 0.01), rand_range(-0.01, 0.01))
			
			# Move the root bone to it's original position
			positions[0] = bones[0].global_transform.origin

			# Go forward through the chain to calculate the positions.
			for index in range(positions.size() - 1):
				var current_index = index
				var next_index = current_index + 1
				var direction = positions[current_index].direction_to(positions[next_index])
				var length = lengths[current_index]
		
				positions[next_index] = positions[current_index] + direction * length
		
		# TODO: This bit is inspired by the original FABRIK paper, but I don't think I've implemented it correctly.
		# It's suposed to stop the snappy-ness. It works for when the target moves away, but does not work for moving in.
		allow_reach = last_leaf_position.distance_to(positions[positions.size() - 1]) < tolerance
		last_leaf_position = positions[positions.size() - 1]
	
	if debug:
		for index in range(1, positions.size()):		
			if positions[index - 1].distance_to(positions[index]) > lengths[index - 1] + 0.001:
				# If the distances between joints is bigger than expected, make the lines go red because it's bad!
				DebugDraw.draw_line_3d(positions[index - 1], positions[index], Color.red)
			else:
				DebugDraw.draw_line_3d(positions[index - 1], positions[index], Color.white)
	
	# Apply all the positions to the bones after calculation	
	for index in range(positions.size()):			
		bones[index].global_transform.origin = positions[index]
	
		# Rotation adjustment **must** come after setting the position to avoid an effect where
		# the joints don't look like they are connecting when the target or pole move too fast.
		if index < positions.size() - 1:
			bones[index].look_at(positions[index + 1], Vector3.UP)
