extends Switch


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func is_weight():
	var circle = RectangleShape2D.new()
	circle.set_extents(Vector2(6, 1))
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(circle)
	params.set_transform(Transform2D(0, global_position+Vector2(0, -4)))
	var state = get_world_2d().get_direct_space_state()
	var results = state.intersect_shape(params)
	
	for result in results:
		var object = result.collider
		if object != self and !object.is_in_group("items"):
			return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_weight() and !is_on:
		set_on(true)
	if !is_weight() and is_on:
		set_on(false)
	pass
