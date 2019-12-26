extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)
var velocity = Vector2()
var push = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR, false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			#collision.collider.apply_impulse(collision.position - collision.collider.position, -collision.normal * push)
			collision.collider.apply_central_impulse(-collision.normal * push)
			# Depending on your character's movement speed, adjust push_factor to
			# something between 0 and 1.
