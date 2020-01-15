extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _loaded_position

func saved():
	return ["position"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func damage(amount):
	queue_free()
	pass
	
func _load():
	_loaded_position = position

func _physics_process(delta):
	if _loaded_position != null:
		global_transform.origin = _loaded_position
		_loaded_position = null
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
