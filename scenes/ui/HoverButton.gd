extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var is_mouse_over = false
var hover_wait_time = 0
var hover_wait = .25

var is_up = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", self, "mouse_entered")
	connect("mouse_exited", self, "mouse_exited")
	pass # Replace with function body.

func mouse_entered():
	is_mouse_over = true

func mouse_exited():
	is_mouse_over = false
	
func _process(delta):
	if not is_mouse_over or not is_up:
		hover_wait_time += delta
		if hover_wait_time >= hover_wait:
			is_up = !is_up
			rect_position += Vector2(0, -1 if is_up else 1)
			hover_wait_time = 0
