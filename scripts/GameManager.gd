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

# Called when the node enters the scene tree for the first time.
func _ready():
	scene = get_tree().get_current_scene()
	camera = camera_scene.instance()
	add_child(camera)
	camera.set_fade(true, true)
	inventory = camera.get_node("CanvasLayer/Stats/Inventory")
	reader = camera.get_node("CanvasLayer/Stats/Reader")
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
	yield(get_tree().create_timer(1.5), "timeout")
	change_scene("Wilderness")
	
func player_died():
	game_over()
	
func pet_died():
	game_over()
	
func game_over():
	#yield(get_tree().create_timer(0), "timeout")
	change_scene(get_scene_name(), "", true)
	
func get_scene_name():
	return get_tree().get_current_scene().get_name()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_restart"):
		change_scene("Main")
		
var is_changing_scenes = false

func change_scene(scene_name, path_name = "", reset = false):
	SaveManager.save_game()
	
	if is_changing_scenes:
		return
		
	is_changing_scenes = true
	
	yield(camera.set_fade(true), "completed")

	camera.set_enable_follow_smoothing(false)
	#yield(get_tree().create_timer(.5), "timeout")
	last_scene_name = get_scene_name()
	last_path_name = path_name
	scene.queue_free()
	get_tree().get_root().remove_child(scene)
	
	if reset:
		#player.set_active(false)
		#pet.set_active(false)
		yield(get_tree(), "idle_frame")
		
	scene = load("res://scenes/"+scene_name+".tscn").instance()
	get_tree().get_root().add_child(scene)
	get_tree().set_current_scene(scene)
	
	yield(get_tree(), "idle_frame")
	load_scene()
	
	is_changing_scenes = false

# Eventually handle multiple points of access between different scenes here
func load_world():
	player.set_active(true)
	pet.set_active(true)
		
	var maps = get_children_by_type(scene, "TileMap")
	var max_pos = Vector2(-1000,-1000)
	var min_pos = Vector2(1000,1000)
	for map in maps:
		var map_max_pos = map.map_to_world(map.get_used_rect().end)
		var map_min_pos = map.map_to_world(map.get_used_rect().position)
		max_pos = Vector2(max(max_pos.x, map_max_pos.x), max(max_pos.y, map_max_pos.y))
		min_pos = Vector2(min(min_pos.x, map_min_pos.x), min(min_pos.y, map_min_pos.y))
	world_rect = Rect2(min_pos, max_pos-min_pos)
	camera.set_bounds(world_rect)
	create_boundary(world_rect)
	
	var spawners = get_tree().get_nodes_in_group("spawners")
	var player_spawner
	var is_path = not last_path_name == ""
	var default_spawner
	for spawner in spawners:
		if spawner.scene_name == "":
			default_spawner = spawner
		if (is_path and spawner.path_name == last_path_name) or (!is_path and spawner.scene_name == last_scene_name):
			player_spawner = spawner
			break
			
	if player_spawner == null:
		player_spawner = default_spawner
		
	if !player_spawner:
		if len(spawners) > 0:
			player_spawner = spawners[0]
		else:
			print("ERROR: SPAWNER MISSING!")
			return
		
	#	return
	player.global_position = player_spawner.global_position+Vector2(-8,0)
	player.set_flip_h(player_spawner.flip_h)
	player.silence()
	pet.global_position = player_spawner.global_position+Vector2(8,0)
	pet.set_flip_h(player_spawner.flip_h)
	camera.snap_position()
	
	SaveManager.load_game()
	yield(get_tree(), "idle_frame")
	yield(camera.set_fade(false), "completed")
	#camera.set_enable_follow_smoothing(true)
	
func create_boundary(world_rect):
	var body = KinematicBody2D.new()
	body.position = Vector2(0,0)
	scene.add_child(body)
	
	var collider_left = CollisionShape2D.new()
	body.add_child(collider_left)
	var shape_left = RectangleShape2D.new()
	shape_left.set_extents(Vector2(16, world_rect.size.y))
	collider_left.set_shape(shape_left)
	collider_left.position = Vector2(world_rect.position.x-16, world_rect.size.y/2)
	
	var collider_right = CollisionShape2D.new()
	body.add_child(collider_right)
	var shape_right = RectangleShape2D.new()
	shape_right.set_extents(Vector2(16, world_rect.size.y))
	collider_right.set_shape(shape_left)
	collider_right.position = Vector2(world_rect.end.x+16, world_rect.size.y/2)
	
func get_children_by_type(node, type):
	var count = 0
	var children = []
	for child in node.get_children():
		if child.is_class(type): 
		   children.append(child)

	return children
	
func auto_indent(text, line_limit=14, tolerance = 4):
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

