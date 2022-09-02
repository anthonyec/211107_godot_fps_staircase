extends Spatial

export var debug: bool = false
export var target_path: NodePath
export var pole_path: NodePath
export var iterations: int = 10;
export var pole_enabled: bool = true

onready var target: Spatial = get_node(target_path)
onready var pole: Spatial = get_node(pole_path)

var is_error: bool = false
var bones = []
# Joint positions are stored seperatly from the bones so that they can be calculated on and
# then applied after all the calculations.
var positions = []
# Distances between each joint.
var lengths = []
var total_length = 0

func _ready() -> void:
	bones = get_children()
	
	for index in range(bones.size()):
		var bone = bones[index]
		positions.append(bone.global_transform.origin)

		if index > 0:
			var distance = bones[index - 1].global_transform.origin.distance_to(bones[index].global_transform.origin)
			lengths.append(distance)
			total_length = total_length + distance

func _process(_delta: float) -> void:	
	if is_error:
		return
		
	if !target_path:
		print("IK: No target path set")
		is_error = true
		return
		
	if pole_enabled and !pole_path:
		print("IK: No pole path set")
		is_error = true
		return
		
	if bones.empty():
		print("IK: No children, no bones!")
		is_error = true
		return
		
	solve()
	
func get_plane(global_position: Vector3, normal: Vector3) -> Plane:	
	var right = normal.cross(Vector3.UP).normalized()
	var up = normal.cross(right).normalized()
	var plane = Plane(
		global_position + right,
		global_position - right,
		global_position + up
	)
	
	return plane

func solve() -> void:
	# Get positions of all bones.
	for index in range(bones.size()):
		positions[index] = bones[index].global_transform.origin
		
	# If the target distance is greater than the total length then move all
	# bones towards the target except the first bone.
	## TODO: Work out why this is so snappy!
	if positions[0].distance_to(target.global_transform.origin) > total_length:
		var direction = positions[0].direction_to(target.global_transform.origin)

		for index in range(1, positions.size()):
			positions[index] = positions[index - 1] + (direction * lengths[index - 1])
	else:
		if pole_enabled:
			# Pull all joints except the root and lead slightly towards the pole position before solving. 
			# It's a naive solution to ensure the IK chain bends towards the pole. Inspired by:
			# TODO: Add resource links here.
			# TODO: Explain why this is done before solve iterations.
			for _iteration in range(iterations):
				for index in range(positions.size() - 2):
					var next_index = index + 1
					var length = lengths[index]
					var difference_between_bone_and_pole = pole.global_transform.origin - positions[next_index]
					var clamped_distance_between_bone_and_pole = clamp(difference_between_bone_and_pole.length(), 0, length)
					
					# TODO: Explain why it's like this.					
					positions[next_index] = positions[next_index] + (difference_between_bone_and_pole.normalized() * clamped_distance_between_bone_and_pole * 0.5)

				
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
				
				# TODO: Find a nice way to right the if statement and google this problem.
				# If the direction is too staight, it cause the forward algo to not work correctly as 
				# there needs to be some alight variation/bias in the direction.
				if direction == Vector3.RIGHT or direction == Vector3.LEFT or direction == Vector3.UP or direction == Vector3.DOWN or direction == Vector3.FORWARD or direction == Vector3.BACK:
					positions[next_index]  = positions[next_index] + Vector3(rand_range(-0.001, 0.001), rand_range(-0.001, 0.001), rand_range(-0.001, 0.001))
			
			# Move the root bone to it's original position
			positions[0] = bones[0].global_transform.origin

			# Go forward through the chain to calculate the positions.
			for index in range(positions.size() - 1):
				var current_index = index
				var next_index = current_index + 1
				var direction = positions[current_index].direction_to(positions[next_index])
				var length = lengths[current_index]
		
				positions[next_index] = positions[current_index] + direction * length
	
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
