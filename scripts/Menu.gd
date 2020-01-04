extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.connect("button_down", self, "on_start_button_down")
	pass # Replace with function body.

func on_start_button_down():
	GameManager.change_scene("Park")
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
