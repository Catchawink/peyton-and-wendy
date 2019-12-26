extends Node2D

onready var player_scene = preload("res://scenes/characters/Peyton.tscn")
onready var camera_scene = preload("res://scenes/helpers/Camera.tscn")
onready var pet_scene = preload("res://scenes/characters/Wendy.tscn")

var player
var pet
var camera
var scene

# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_scene.instance()
	add_child(player)
	camera = camera_scene.instance()
	player.add_child(camera)
	camera.global_position = player.global_position
	pet = pet_scene.instance()
	add_child(pet)
	load_positions()
	scene = get_tree().get_current_scene()

func load_scene(scene_name):
	yield(camera.set_fade(true), "completed")
	camera.set_enable_follow_smoothing(false)
	#yield(get_tree().create_timer(.5), "timeout")
	scene.queue_free()
	get_tree().get_root().remove_child(scene)
	scene = load("res://scenes/"+scene_name+".tscn").instance()
	get_tree().get_root().add_child(scene)
	get_tree().set_current_scene(scene)
	load_positions()

# Eventually handle multiple points of access between different scenes here
func load_positions():
	var spawner = get_tree().get_nodes_in_group("spawners")[0]
	player.global_position = spawner.global_position+Vector2(-8,0)
	player.set_flip_h(spawner.flip_h)
	pet.global_position = spawner.global_position+Vector2(8,0)
	pet.set_flip_h(spawner.flip_h)
	spawner.visible = false
	camera.position = Vector2(0,0)
	yield(get_tree().create_timer(.1), "timeout")
	yield(camera.set_fade(false), "completed")
	#camera.set_enable_follow_smoothing(true)

