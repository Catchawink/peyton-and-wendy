extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	clear(true)
	pass # Replace with function body.

func read(text):
	$StartPlayer.play()
	$Label.set_text(GameManager.auto_indent(text.to_upper(), 25))
	visible = true
	
func clear(immediate=false):
	$Label.set_text("")
	if !immediate:
		$StopPlayer.play()
	visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
