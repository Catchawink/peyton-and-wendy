tool class_name Event extends Node2D

func saved():
	return ["script", "is_input_locked", "is_one_shot", "auto_start", "has_executed"]

export var is_one_shot = true
export var is_input_locked = false
export var auto_start = false
var is_executing = false

var player
var wizard_horse
var battering_ram
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
	battering_ram = GameManager.get_character(GameManager.Battering_Ram)
	$Area2D.connect("body_entered", self, "body_entered")
	$Area2D.connect("body_exited", self, "body_exited")
	pass # Replace with function body.

func _load():
	if auto_start:
		_execute()
		
var has_player = false
var has_executed = false

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
	if is_one_shot and has_executed:
		return
	is_executing = true
	if is_input_locked:
		GameManager.set_lock_input(true)
	yield(execute(), "completed")
	if is_input_locked:
		GameManager.set_lock_input(false)
	has_executed = true
	is_executing = false
