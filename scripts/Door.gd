tool extends "Spawner.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var timer
var input_hint
var priority = 1

# Called when the node enters the scene tree for the first time.
func on_ready():
	if Engine.editor_hint:
		return
	$Area2D.connect("body_entered", self, "body_entered")
	$Area2D.connect("body_exited", self, "body_exited")
	input_hint = load("res://scenes/ui/InputHint.tscn").instance()
	add_child(input_hint)
	input_hint.set_position(Vector2(0,-37))
	input_hint.visible = false
	pass # Replace with function body.

var has_player = false

func body_entered(var body):
	if body == GameManager.player:
		has_player = true
		GameManager.player.register(self)
	
func body_exited(var body):
	if body == GameManager.player:
		has_player = false
		GameManager.player.deregister(self)
		
func start_use():
	GameManager.change_scene(scene_name, path_name)
	$AudioStreamPlayer.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	input_hint.visible = has_player
