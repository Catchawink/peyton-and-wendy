tool extends Node2D

func saved():
	return ["script", "is_input_locked", "is_one_shot", "auto_start"]

export var is_one_shot = true
export var is_input_locked = false
export var auto_start = false
var is_executing = false

var player
var wizard_horse
var pet

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
		
	if !visible:
		queue_free()
	visible = false
		
	player = GameManager.player
	pet = GameManager.pet
	wizard_horse = GameManager.get_character(GameManager.Wizard_Horse)
	
	$Area2D.connect("body_entered", self, "body_entered")
	$Area2D.connect("body_exited", self, "body_exited")
	
	if auto_start:
		_execute()
	pass # Replace with function body.

var has_player = false

func body_entered(var body):
	if body == player:
		has_player = true
		
func body_exited(var body):
	if body == player:
		has_player = false
		
func execute():
	pass

func is_valid():
	return true
	
func _process(delta):
	if !is_executing and !auto_start and has_player and abs(global_position.x-player.global_position.x) < 2 and is_valid():
		_execute()

func _execute():
	is_executing = true
	if is_input_locked:
		GameManager.lock_input()
	yield(execute(), "completed")
	if is_input_locked:
		GameManager.unlock_input()
	is_executing = false
	if is_one_shot:
		queue_free()
