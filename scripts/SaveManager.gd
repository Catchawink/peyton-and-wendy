extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const auto_save = ["name", "rotation_degrees"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func get_node_data(node, use_path = true):
	var data = {}
	var properties = node.get_property_list()
	if use_path:
		data["path"] = node.get_path()
	data["filename"] = node.get_filename()
	
	for property_name in auto_save:
		data[property_name] = node.get(property_name)
		
	if node.has_method("saved"):
		for property_name in node.call("saved"):
			if property_name == "position":
				data["pos_x"] = node.position.x
				data["pos_y"] = node.position.y
			else:
				var value = null
				if node.get(property_name) is Resource:
					value = node.get(property_name).get_path()
				else:
					value = node.get(property_name)
				data[property_name] = value
	return data
	
func get_scene_data():
	#print(GameManager.get_scene_name() + ", " + str(len(get_tree().get_nodes_in_group("saved"))))
	return get_nodes_data(get_tree().get_nodes_in_group("saved"))

func get_nodes_data(nodes, use_path = true):
	var data = []
	for node in nodes:
		data.append(get_node_data(node, use_path))
	return data
	
func delete_game():
	var dir = Directory.new()
	dir.remove(save_path)
	
func save_game():
	var data = get_data()
	var item_data = []
	data["Inventory"] = {}
	data["Inventory"]["items"] = get_nodes_data(GameManager.inventory.items, false)
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
	var node
	if "path" in data:
		node = get_node(data["path"])
	else:
		node = load(data["filename"]).instance()

	# Now we set the remaining variables.
	print("LOADING " + node.name)
	for property_name in data.keys():
		if property_name == "filename" or property_name == "path":
			continue
		var value = data[property_name]
		print(property_name + ", " + str(value))
		if property_name == "pos_x":
			node.position.x = value
		elif property_name == "pos_y":
			node.position.y = value
		elif property_name == "script":
			node.set(property_name, load(value))
			#node.get_script().set_source_code(load(value).get_source_code())
			#node.get_script().reload(true)
		else:
			node.set_deferred(property_name, value)
	if "path" in data:
		if node.has_method("_load"):
			node.call_deferred("_load")
	else:
		GameManager.scene.call_deferred("add_child",node)
	return node
	
func unsave(node):
	if node.is_in_group("saved"):
		node.remove_from_group("saved")
	return node
	
func copy(node):
	return unsave(set_node_data(get_node_data(node, false)))
		
func load_game():
	var data = get_data()
	
	if data.has("Inventory"):
		GameManager.inventory.clear()

		for item_data in data["Inventory"]["items"]:
			var item = unsave(set_node_data(item_data))
			yield(get_tree(), "idle_frame")
			item.set_physics_active(false)
			yield(get_tree(), "idle_frame")
			GameManager.inventory.add_item(item)
		
		#GameManager.inventory.select_item_by_index(int(data["Inventory"]["current_item_index"]))
	if data.has(GameManager.get_scene_name()):
		#print(GameManager.get_scene_name())
		var scene_data = data[GameManager.get_scene_name()]
		#print(len(scene_data))
		for node_data in scene_data:
			set_node_data(node_data)
	else:	
		var save_nodes = get_tree().get_nodes_in_group("saved")
		for i in save_nodes:
			if i.has_method("_load"):
				i.call_deferred("_load")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
