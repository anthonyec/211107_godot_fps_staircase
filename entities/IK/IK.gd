extends Spatial

export var target_path: NodePath
export var pole_path: NodePath
export var iterations: int = 10;

onready var target: Spatial = get_node(target_path)
onready var pole: Spatial = get_node(pole_path)

var is_error: bool = false
var bones = []
var positions = []
var lengths = []
var total_length = 0

func transform_y(target: Spatial, normal: Vector3) -> void:
	var rotation_axis = Vector3.UP.cross(normal).normalized()
	var rotation_angle = Vector3.UP.angle_to(normal)
	target.transform.basis = Basis(rotation_axis, rotation_angle)

func _ready() -> void:
	bones = $Bones.get_children()
	
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
		print("IKSolver: No target set")
		is_error = true
		return
		
	if bones.empty():
		print("IKSolver: No children, no bones!")
		is_error = true
		return
		
	solve()

func solve() -> void:
	# Get positions of all bones.
	for index in range(bones.size()):
		positions[index] = bones[index].global_transform.origin
		
	# If the target distance is greater than the total length then move all
	# bones towards the target except the first bone.
	if bones[0].global_transform.origin.distance_squared_to(target.global_transform.origin) >= total_length * total_length:
		var direction = bones[0].global_transform.origin.direction_to(target.global_transform.origin)
		
		for index in range(1, positions.size()):
			positions[index] = positions[index - 1] + (direction * lengths[index - 1])
	else:
		for iteration in range(iterations):
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
	
	# Apply all the positions to the bones after calculation	
	for index in range(positions.size()):
		bones[index].global_transform.origin = positions[index]
		
