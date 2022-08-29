extends Spatial

export var target_path: NodePath
export var pole_path: NodePath
export var iterations: int = 1;
export var bone_length: float = 1

onready var target: Spatial = get_node(target_path)
onready var pole: Spatial = get_node(pole_path)

var is_error: bool = false
var bones

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
	pass
