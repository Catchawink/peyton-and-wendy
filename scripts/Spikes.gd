extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "body_entered")
	pass # Replace with function body.


func body_entered(var body):
	if body is Character:
		body.die()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
