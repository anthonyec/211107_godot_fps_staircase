extends Spatial

onready var prop: RigidBody = $EntityTesterScene/PhysicsProp

var direction: float = 1
var speed: float = 5

func _process(delta: float) -> void:
	prop.apply_central_impulse((Vector3.FORWARD * speed * delta) * direction)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		direction = -1
		
	if event.is_action_pressed("ui_right"):
		direction = 1
		
	if event.is_action_pressed("ui_accept"):
		if speed == 5:
			speed = 10
		else:
			speed = 5
