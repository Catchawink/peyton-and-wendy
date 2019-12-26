extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var input_hint_scene = preload("res://scenes/ui/InputHint.tscn")
export var scene_name = ""
var timer
var input_hint

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.connect("body_entered", self, "body_entered")
	$Area2D.connect("body_exited", self, "body_exited")
	input_hint = input_hint_scene.instance()
	add_child(input_hint)
	input_hint.set_position(Vector2(0,-37))
	input_hint.visible = false
	yield (wait(.05), "completed")
	pass # Replace with function body.

func wait(seconds):
	while true:
		yield(get_tree().create_timer(.05), "timeout")
		
var has_player = false

func body_entered(var body):
	if body == GameManager.player:
		has_player = true
	
func body_exited(var body):
	if body == GameManager.player:
		has_player = false
	
func count_nodes(type):
	var count = 0

	for node in get_tree().root.get_children():
		if node.get_class() == type: 
			count += 1

	return count
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	input_hint.visible = has_player
	if has_player and Input.is_action_just_pressed("ui_examine"):
		print(count_nodes("Timer"))
		GameManager.load_scene(scene_name)
		$AudioStreamPlayer.play()
