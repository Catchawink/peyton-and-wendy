extends Node2D

onready var player_scene = preload("res://scenes/characters/Peyton.tscn")
onready var pet_scene = preload("res://scenes/characters/Wendy.tscn")

export var default_scene = ""
var player
var pet
var scene

# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_scene.instance()
	add_child(player)
	pet = pet_scene.instance()
	add_child(pet)

func load_scene(scene_name):
	if scene:
		scene.queue_free()
		
	get_tree().change_scene("res://scenes/"+scene_name+".tscn")
