extends PanelContainer

onready var item_scene = preload("res://scenes/ui/Item.tscn")

#signal item_selected

var items = []
var display_items = {}
var current_item
var current_index = -1

var is_active = false

signal item_added

# Called when the node enters the scene tree for the first time.
func _ready():
	update_visibility(false)
	pass # Replace with function body.

func set_active(value):
	is_active = value
	update_visibility()
	
func select_left():
	if current_index > 0:
		$ClickPlayer.play()
		select_item(items[current_index-1])
		
func select_right():
	if current_index < len(items)-1:
		$ClickPlayer.play()
		select_item(items[current_index+1])
	
func add_item(item):
	var item_display = item_scene.instance()
	$Items.add_child(item_display)
	item_display.get_node("TextureRect").set_texture(item.get_node("Sprite").get_texture())
	items.append(item)
	display_items[item] = item_display
	item.visible = false
	if len(items) == 1:
		select_item(item)
	update_visibility()
	emit_signal("item_added", item)
	
func clear():
	while len(items) > 0:
		remove_item(items[0])

func remove_item(item):
	display_items[item].queue_free()
	display_items.erase(item)
	item.queue_free()
	items.erase(item)
	if item == current_item:
		current_item = null
	pass
	
func select_item(item):
	if current_item:
		current_item.visible = false
		current_item.deselect()
		if is_using:
			stop_use()
		display_items[current_item].get_node("Outline").visible = false
	current_item = item
	current_index = items.find(current_item)
	
	current_item.select()
	if current_item.use_hand:
		current_item.visible = true
	display_items[item].get_node("Outline").visible = true
	#emit_signal("item_selected", current_item)

var is_using = false

func start_use():
	is_using = true
	current_item.start_use()
	
func stop_use():
	if is_using:
		is_using = false
		current_item.stop_use()
	
func update_visibility(play_sfx = true):
	var old_visible = visible
	visible = is_active and (len(items) > 0)
	if old_visible != visible:
		if visible:
			if play_sfx:
				$OpenPlayer.play()
		else:
			if play_sfx:
				$ClosePlayer.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
