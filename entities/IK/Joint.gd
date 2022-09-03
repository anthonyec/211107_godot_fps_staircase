extends Spatial

export var show_axis: bool = true

onready var axis: Spatial = $Axis

func _ready() -> void:
	axis.visible = show_axis
