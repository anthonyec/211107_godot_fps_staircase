extends Spatial

export(Array, Resource) var items

onready var item_position: Position3D = $ItemPosition

var current_child_index: int = 0

func _ready() -> void:		
	switch_to_item(0)

func get_item(index: int):
	if not items.empty() and index < items.size():
		var item_resouce = items[index]
		var item = item_resouce.fps_view_scene.instance()
		
		return item
	
func switch_to_item(index: int):
	var item = get_item(index)
	
	if !item:
		return
		
	if item_position.get_child_count() > 0 and item_position.get_child(0):
		item_position.remove_child(item_position.get_child(0))
	
	if item.has_signal("consumed"):
		item.connect("consumed", self, "on_item_consumed", [index])
		
	if item.has_signal("recoiled"):
		item.connect("recoiled", self, "on_item_recoiled")
		
	item_position.add_child(item)
	current_child_index = index

func previous_item():
	var index = wrapi(current_child_index - 1, 0, get_child_count())
	switch_to_item(index)
		
func next_item():
	var index = wrapi(current_child_index + 1, 0, get_child_count())
	switch_to_item(index)

func on_item_consumed(index: int) -> void:
	print("on_item_consumed")
	
func on_item_recoiled() -> void:
	print("recoil camera")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select_item_1"):
		switch_to_item(0)
		
	if event.is_action_pressed("select_item_2"):
		switch_to_item(1)
		
	if event.is_action_pressed("select_item_3"):
		switch_to_item(2)
		
	if event.is_action_pressed("select_item_4"):
		switch_to_item(3)
		
	if event.is_action_pressed("previous_item"):
		previous_item()
		
	if event.is_action_pressed("next_item"):
		next_item()
