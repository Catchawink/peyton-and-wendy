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
		
	for property_name in node.get("saved"):
		data[property_name] = node.get(property_name)
	#for property in node.get_property_list():
	#	if(property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE):
	#		print(node.name + ", " + property.name)
	#		data[property.name] = node.get(property.name)
	return data
	
func get_scene_data():
	return get_nodes_data(get_tree().get_nodes_in_group("saved"))

func get_nodes_data(nodes):
	var data = []
	for node in nodes:
		data.append(get_node_data(node))
	return data
	
func save_game():
	var data = get_data()
	var item_data = []
	data["Inventory"] = get_nodes_data(GameManager.inventory.items)
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
	
func load_node(data):
	var node = load(data["filename"]).instance()
	get_node(data["parent"]).add_child(node)
	node.position = Vector2(data["pos_x"], data["pos_y"])
	# Now we set the remaining variables.
	for i in data.keys():
		if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
			continue
		node.set(i, data[i])
	return node
		
func copy(node):
	return load_node(get_node_data(node))
		
func load_game():
	var data = get_data()
	
	if data.has("Inventory"):
		GameManager.inventory.clear()
		var inventory_data = data["Inventory"]
		for item_data in inventory_data:
			var item = load_node(item_data)
			print("Added item named " + item.name)
			GameManager.inventory.add_item(item)
			
	if data.has(GameManager.get_scene_name()):
		print("SaveManager has data for " + GameManager.get_scene_name())
		var scene_data = data[GameManager.get_scene_name()]
			
		var save_nodes = get_tree().get_nodes_in_group("saved")
		for i in save_nodes:
			i.queue_free()
			
		for node_data in scene_data:
			load_node(node_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
