tool
extends Spatial

export var show_floor: bool = true

onready var scene_floor: Spatial = $Floor

func _ready() -> void:
	scene_floor.visible = show_floor
