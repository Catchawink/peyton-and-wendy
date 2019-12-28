tool extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var scene_name = ""
export var path_name = ""
export var flip_h = false

# Called when the node enters the scene tree for the first time.
func _ready():
	on_ready()
	pass # Replace with function body.

func on_ready():
	if !Engine.editor_hint:
		visible = false
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Sprite.set_flip_h(flip_h)
	pass
