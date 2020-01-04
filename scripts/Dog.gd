extends "Character.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var acting_velocity = Vector2(0,0)

func init():
	.init()
	act()
	
func act():
	while (true):
		yield(get_tree().create_timer(rand_range(.5, 4)), "timeout")
		var is_idle = bool(randi() % 2)
		if is_idle:
			acting_velocity.x = 0
		else:
			var is_right = bool(randi() % 2)
			acting_velocity.x = (1 if is_right else -1)*speed
		
func process_input(delta):
	if is_wall() and acting_velocity.x != 0:
		velocity.x = -velocity.x
	velocity = acting_velocity
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
