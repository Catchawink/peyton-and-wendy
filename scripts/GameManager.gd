extends Node2D

onready var player_scene = preload("res://scenes/characters/Peyton.tscn")
onready var camera_scene = preload("res://scenes/helpers/Camera.tscn")
onready var pet_scene = preload("res://scenes/characters/Wendy.tscn")

var player
var pet
var camera
var inventory
var reader

var scene
var world_rect

const Wizard_Horse = "WizardHorse"
const Peyton = "Peyton"
const Wendy = "Wendy"

var is_initialized = false
var last_scene_name = ""
var last_path_name = ""
var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	SaveManager.delete_game()
	
	scene = get_tree().get_current_scene()
	if !is_valid_scene():
		return
		
	is_active = true
	camera = camera_scene.instance()
	add_child(camera)
	camera.set_fade(true, true)
	inventory = camera.get_node("StatsCanvas/Stats/Inventory")
	reader = camera.get_node("StatsCanvas/Stats/Reader")
	world_rect = Rect2(-5000,5000,10000,10000)
	
	player = player_scene.instance()
	player.connect("died", self, "player_died")
	add_child(player)
	camera.set_target(player)
	pet = pet_scene.instance()
	pet.connect("died", self, "pet_died")
	add_child(pet)
	
	load_scene()
	
func load_scene():
	SaveManager.load_game()
	GameManager.unlock_input()
	camera.set_tint(Color(0,0,0,0), 0)
	if get_scene_name() == "Main":
		load_main()
	else:
		load_world()
		
func lock_input():
	player.is_input_locked = true

func unlock_input():
	player.is_input_locked = false
		
func get_character(character_name):
	var characters = get_tree().get_nodes_in_group("characters")
	for character in characters:
		if character.name == character_name:
			return character
	return null
	
func load_main():
	player.set_active(false)
	pet.set_active(false)
	yield(get_tree(), "idle_frame")
	yield(camera.set_fade(false), "completed")
	scene.get_node("AudioStreamPlayer").play()
	yield(get_tree().create_timer(2), "timeout")
	change_scene("Menu")
	
func pickup(item_name, is_immediate=false):
	yield(player.pickup(spawn_item(item_name), is_immediate), "completed")
	
func player_died():
	game_over()
	
func pet_died():
	game_over()
	
func game_over():
	#yield(get_tree().create_timer(0), "timeout")
	change_scene(get_scene_name(), "", true)
	
func get_scene_name():
	return scene.filename.get_file().replace("."+scene.filename.get_extension(), "")
	
func _process(delta):
	if Input.is_action_just_pressed("ui_restart"):
		change_scene("Main")
		
var is_changing_scenes = false

func is_valid_scene():
	return scene.filename.replace(scene.filename.get_file(), "") == "res://scenes/"
		
func get_scene_path(scene_name):
	return "res://scenes/"+scene_name+".tscn"
	
func change_scene(scene_name, path_name = "", reset = false):
	SaveManager.save_game()
	
	if is_changing_scenes:
		return
		
	is_changing_scenes = true
	
	SoundManager.clear()
	yield(camera.set_fade(true), "completed")
	player.get_parent().remove_child(player)
	self.add_child(player)
	player.set_active(false)
	pet.set_active(false)
	
	camera.set_enable_follow_smoothing(false)
	#yield(get_tree().create_timer(.5), "timeout")
	last_scene_name = get_scene_name()
	last_path_name = path_name
	scene.queue_free()
	get_tree().get_root().remove_child(scene)
	world_rect = Rect2(-5000,5000,10000,10000)

	scene = load(get_scene_path(scene_name)).instance()
	get_tree().get_root().add_child(scene)
	get_tree().set_current_scene(scene)
	scene.global_position = Vector2(0,0)
	
	yield(get_tree(), "idle_frame")
	if reset:
		player.reset()
		pet.reset()
	load_scene()
	is_changing_scenes = false

func get_maps():
	return get_children_by_type(scene, "TileMap")
	
func load_world():

	var spawners = get_tree().get_nodes_in_group("spawners")
	var player_spawner
	var is_path = not last_path_name == ""
	var default_spawner
	#print(get_scene_name())
	for spawner in spawners:
		if spawner.scene_name == "":
			default_spawner = spawner
		#print(str(is_path)+", " + last_path_name + ", " + last_scene_name +", " +spawner.scene_name )
		if (is_path and spawner.path_name == last_path_name) or (!is_path and spawner.scene_name == last_scene_name):
			player_spawner = spawner
			break
			
	if player_spawner == null:
		player_spawner = default_spawner
		
	if !player_spawner:
		if len(spawners) > 0:
			player_spawner = spawners[0]

	#	return
	if player_spawner:
		player.set_flip_h(player_spawner.flip_h)
		player.get_parent().remove_child(player)
		player_spawner.get_parent().add_child(player)
		player.global_position = player_spawner.get_spawn_pos()+Vector2(8*player.get_flip_sign(),0)
		player.silence()
		pet.set_flip_h(player_spawner.flip_h)
		pet.global_position = player_spawner.get_spawn_pos()+Vector2(8*-player.get_flip_sign(),0)
		
		var maps = get_maps()
		var max_pos = Vector2(-100000,-100000)
		var min_pos = Vector2(100000,100000)
		for map in maps:
			if len(map.get_used_cells()) == 0:
				continue
			var map_max_pos = map.global_position+map.map_to_world(map.get_used_rect().end)
			var map_min_pos = map.global_position+map.map_to_world(map.get_used_rect().position)
			max_pos = Vector2(max(max_pos.x, map_max_pos.x), max(max_pos.y, map_max_pos.y))
			min_pos = Vector2(min(min_pos.x, map_min_pos.x), min(min_pos.y, map_min_pos.y))
		#min_pos += Vector2(0,-16)
		world_rect = Rect2(min_pos, max_pos-min_pos)
		camera.set_bounds(world_rect)
		create_boundary(world_rect)
		camera.snap_position()
	
		yield(get_tree(), "idle_frame")
		
		player.set_active(true)
		pet.set_active(true)
	yield(camera.set_fade(false), "completed")
	#camera.set_enable_follow_smoothing(true)
	
func spawn_item(item_name):
	item_name = item_name[0].to_upper() + item_name.substr(1, len(item_name)-1)
	var item = load("res://scenes/items/"+item_name+".tscn").instance()
	SaveManager.unsave(item)
	scene.add_child(item)
	return item
	
func create_boundary(world_rect):
	var body = KinematicBody2D.new()
	body.position = Vector2(0,0)
	scene.add_child(body)
	
	var collider_left = CollisionShape2D.new()
	body.add_child(collider_left)
	var shape_left = RectangleShape2D.new()
	shape_left.set_extents(Vector2(16, world_rect.size.y))
	collider_left.set_shape(shape_left)
	collider_left.position = Vector2(world_rect.position.x-16, world_rect.position.y+world_rect.size.y/2)
	
	var collider_right = CollisionShape2D.new()
	body.add_child(collider_right)
	var shape_right = RectangleShape2D.new()
	shape_right.set_extents(Vector2(16, world_rect.size.y))
	collider_right.set_shape(shape_left)
	collider_right.position = Vector2(world_rect.end.x+16, world_rect.position.y+world_rect.size.y/2)
	
func get_children_by_type(node, type):
	var count = 0
	var children = []
	for child in node.get_children():
		if child.is_class(type): 
		   children.append(child)

	return children
	
func auto_indent(text, line_limit=13, tolerance = 0):
	var line_length = 0
	var last_index = -1
	text += " "
	for index in range(0,len(text)):
		line_length+=1
		var text_char = text[index]
		if text_char == " ":
			var line_dif = line_length-line_limit
			if line_dif > tolerance:
				text.erase(last_index, 1)
				text = text.insert(last_index, "\n")
				line_length = index-last_index
			last_index = index
	text = text.substr(0, len(text)-1)
	return text

