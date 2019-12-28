extends CenterContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func read(text):
	$StartPlayer.play()
	$Label.set_text(GameManager.auto_indent(text, 25))
	visible = true
	
func clear():
	$Label.set_text("")
	$StopPlayer.play()
	visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
