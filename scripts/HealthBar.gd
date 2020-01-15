extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_health(value):
	for child in get_children():
		var child_num = int(child.name.replace("Heart", ""))
		child.visible = child_num <= value
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
