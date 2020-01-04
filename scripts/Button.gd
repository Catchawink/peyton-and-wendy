extends Switch


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func is_weight():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, global_position+Vector2(0, -5), [self])
	
	if result.empty():
		return false
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_weight() and !is_on:
		set_on(true)
	pass
