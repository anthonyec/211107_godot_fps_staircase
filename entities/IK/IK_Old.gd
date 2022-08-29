extends Spatial

export var target_path: NodePath
export var pole_path: NodePath
export var iterations: int = 1;
export var chain_length: int = 3

onready var target: Spatial = get_node(target_path)
onready var pole: Spatial = get_node(pole_path)

var delta: float = 0.01
var snap_back_strength: float = 1

var bones = []
var positions = []
var bone_lengths = []
var complete_length = 0
	
func _ready() -> void:
	bones.resize(chain_length + 1)
	positions.resize(chain_length + 1)
	bone_lengths.resize(chain_length)
	
	var i = bones.size() - 1;
	var current = self
	
	while i >= 0:
		bones[i] = current

		if i == bones.size() - 1:
			# TODO: What? Why blank?
			pass
		else:
			bone_lengths[i] = bones[i + 1].global_transform.origin.distance_to(current.global_transform.origin)
			complete_length = complete_length + bone_lengths[i]

		current = current.get_parent()
		i = i - 1
	
	print(bones)
	print(bone_lengths)
	print(complete_length)

func _process(delta: float) -> void:
	if !target_path:
		return
		
	if bone_lengths.size() != chain_length:
		_ready()
		
	solve()
	
func solve() -> void:
	# Get positions.
	for index in range(bones.size()):
		positions[index] = bones[index].global_transform.origin
		
	# Calculate positions.
	# Is it possible to reach the target?
	if target.global_transform.origin.distance_squared_to(bones[0].global_transform.origin) >= complete_length * complete_length:
		var direction = target.global_transform.origin.direction_to(positions[0])
		
		for index in range(positions.size() - 1):
			positions[index] = positions[index - 1] + (direction * bone_lengths[index - 1])
	
	else:
		for iteration in range(iterations):
			# Back
			var j = positions.size() - 1
			
			while j > 0:
				if j == positions.size() - 1:
					positions[j] = target.global_transform.origin
				else:
					positions[j] = positions[j + 1] + (positions[j].direction_to(positions[j + 1])	 * bone_lengths[j])
				j = j - 1
				
			# forward
			var k = 1
			
			while k < positions.size():
				positions[k] = positions[k - 1] + (positions[k].direction_to(positions[k - 1]) * bone_lengths[k - 1])
				k = k + 1
		
	# Set positions.
	for index in range(positions.size()):
		 bones[index].global_transform.origin = positions[index]
		
	pass
