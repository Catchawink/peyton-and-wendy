class_name Interactable extends Node2D

export var priority = 1
export var is_automatic = false
var input_hint
var height = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_node("Area2D/CollisionShape2D"):
		height = $Area2D/CollisionShape2D.shape.get_extents().y*2
		$Area2D.connect("body_entered", self, "body_entered")
		$Area2D.connect("body_exited", self, "body_exited")
		input_hint = load("res://scenes/ui/InputHint.tscn").instance()
		add_child(input_hint)
		var offset = Vector2(0,0)
		offset += $Area2D/CollisionShape2D.position
		input_hint.set_position(Vector2(0,-height/2+offset.y-8-1))
		input_hint.visible = false
	pass # Replace with function body.

func on_ready():
	pass
	
var has_player = false

func body_entered(var body):
	if body == GameManager.player:
		has_player = true
		if is_automatic:
			start_use()
		else:
			GameManager.player.register(self)
	
func body_exited(var body):
	if body == GameManager.player:
		has_player = false
		if is_automatic:
			start_use()
		else:
			GameManager.player.deregister(self)
		
var has_focus = false
func set_focus(value):
	has_focus = value
	input_hint.visible = has_focus
	
func start_use():
	pass
	
func stop_use():
	pass
	
func _process(delta):
	pass
