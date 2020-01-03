extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func poof():
	$PoofPlayer.play()
	$Poof.frame = 0
	$Poof.play("poof")
	yield($Poof, "animation_finished")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
