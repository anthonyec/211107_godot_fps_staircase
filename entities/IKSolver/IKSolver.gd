extends Spatial

export var iterations = 1;

onready var chain: Spatial = $Chain
onready var target: Position3D = $Target
onready var pole: Position3D = $Pole

var bone_length = 0.5

var bones = []
var last_target_position: Vector3 
var children

func _ready() -> void:
	last_target_position = target.global_transform.origin
	
	children = $Chain.get_children()
	var children_count = $Chain.get_child_count()
	
	for index in range(children_count):
		var child = children[index]
		var previous_child = children[0] if index == 0 else children[index - 1]
		
		var bone = {
			"child": child,
			"originalPosition": child.global_transform.origin,
			"originalRotation": child.rotation,
			"length": 1,
			
			"position": child.global_transform.origin,
			"up": previous_child.global_transform.origin - child.global_transform.origin
		}
		
		bones.append(bone)

func _process(_delta: float) -> void:	
	solve()
	
func stack_bones_based_on_length() -> void:
	var index = bones.size() - 2
	
	while index >= 0:
#		bones[index]["position"] = bones[index + 1]["position"] + (-bones[index + 1]["up"] * bones[index + 1]["length"])
		children[index].global_transform.origin = children[index + 1].global_transform.origin + (-children[index + 1].global_transform.basis.y * bone_length)
		index = index - 1
		
func solve() -> void:
	var root_position: Vector3 = bones[bones.size() - 1]["position"]
	
#	bones[bones.size() - 1]["up"] = -(pole.global_transform.origin - bones[bones.size() - 1]["position"])
	children[children.size() - 1].look_at(-(pole.global_transform.origin - children[children.size() - 1].global_transform.origin), Vector3.UP)
	
	stack_bones_based_on_length()
	
	for index in range(iterations):
#		bones[0]["up"] = -(target.global_transform.origin - bones[0]["position"])
		children[0].look_at(target.global_transform.origin, Vector3.UP)
		
#		bones[0]["position"] = target.global_transform.origin - (-bones[0]["up"] * bones[0]["length"])
		children[0].global_transform.origin = target.global_transform.origin - (-children[0].global_transform.basis.y * bone_length)
	
		for j in range(bones.size()):
#			bones[j]["up"] = -(bones[j - 1]["position"] - bones[j]["position"])
			children[j].look_at(children[j - 1].global_transform.origin, Vector3.UP)
			
#			bones[j]["position"] = bones[j - 1]["position"] - (-bones[j]["up"] * bones[j]["length"])
			children[j].global_transform.origin = children[j -1].global_transform.origin - (-children[j].global_transform.basis.y * bone_length)
		
#		bones[bones.size() - 1]["position"] = root_position
		children[children.size() - 1].global_transform.origin = root_position
		
#		var j = bones.size() - 2
		var j = children.size() - 2
	
		while j >= 0:
#			bones[j]["position"] = bones[j + 1]["position"] + (-bones[j + 1]["up"] * bones[j + 1]["length"])
			children[j].global_transform.origin = children[j + 1].global_transform.origin + (-children[j + 1].global_transform.basis.y * bone_length)
			j = j - 1
		
		last_target_position = target.global_transform.origin

