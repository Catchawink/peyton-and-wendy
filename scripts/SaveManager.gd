extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const auto_save = ["name", "rotation_degrees"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func get_node_data(node):
	var data = {}
	var properties = node.get_property_list()
	data["parent"] = node.get_parent().get_path()
	data["filename"] = node.get_filename()
	data["pos_x"] = node.position.x
	data["pos_y"] = node.position.y
	
	for property_name in auto_save:
		data[property_name] = node.get(property_name)
		
	if node.has_method("saved"):
		for property_name in node.call("saved"):
			var value = null
			if node.get(property_name) is Resource:
				value = node.get(property_name).get_path()
			else:
				value = node.get(property_name)
			data[property_name] = value
	return data
	
func get_scene_data():
	return get_nodes_data(get_tree().get_nodes_in_group("saved"))

func get_nodes_data(nodes):
	var data = []
	for node in nodes:
		data.append(get_node_data(node))
	return data
	
func delete_game():
	var dir = Directory.new()
	dir.remove(save_path)
	
func save_game():
	var data = get_data()
	var item_data = []
	data["Inventory"] = {}
	data["Inventory"]["items"] = get_nodes_data(GameManager.inventory.items)
	data["Inventory"]["current_item_index"] = GameManager.inventory.current_item_index
	data[GameManager.get_scene_name()] = get_scene_data()
	set_data(data)
	
const save_path = "user://Game.save"
	
func set_data(data):
	var save_game = File.new()
	save_game.open(save_path, File.WRITE)
	save_game.store_string(to_json(data))
	save_game.close()

func get_data():
	var save_game = File.new()
	if not save_game.file_exists(save_path):
		return {}
		
	save_game.open(save_path, File.READ)
	var text = save_game.get_as_text()
	save_game.close()
	if len(text) == 0:
		return {}
		
	var data = parse_json(text)
	if data == null:
		return {}
	return data
	
func set_node_data(data):
	var node = load(data["filename"]).instance()
	node.position = Vector2(data["pos_x"], data["pos_y"])
	# Now we set the remaining variables.
	for property_name in data.keys():
		if property_name == "filename" or property_name == "parent" or property_name == "pos_x" or property_name == "pos_y":
			continue
		var value = data[property_name]
		if property_name == "script":
			node.set(property_name, load(value))
			#node.get_script().set_source_code(load(value).get_source_code())
			#node.get_script().reload(true)
		else:
			node.set(property_name, value)
	get_node(data["parent"]).add_child(node)
	
	return node
		
func unsave(node):
	if node.is_in_group("saved"):
		node.remove_from_group("saved")
	return node
	
func copy(node):
	return unsave(set_node_data(get_node_data(node)))
		
func load_game():
	var data = get_data()
	
	if data.has("Inventory"):
		GameManager.inventory.clear()

		for item_data in data["Inventory"]["items"]:
			var item = unsave(set_node_data(item_data))
			GameManager.inventory.add_item(item)
		
		GameManager.inventory.select_item_by_index(int(data["Inventory"]["current_item_index"]))
			
	if data.has(GameManager.get_scene_name()):
		var scene_data = data[GameManager.get_scene_name()]
			
		var save_nodes = get_tree().get_nodes_in_group("saved")
		for i in save_nodes:
			i.queue_free()
			
		for node_data in scene_data:
			set_node_data(node_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
