extends Spatial

signal recoiled

onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	get_node("OmniLight").light_energy = 0

func shoot() -> void:
	if animation.is_playing():
		return

	SFX.play_at_location("weapons/shotgun/shotgun_fire{%n}", global_transform.origin)
	animation.play("shoot")
	emit_signal("recoiled")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item"):
		shoot()
