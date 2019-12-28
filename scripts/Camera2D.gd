extends Camera2D

#export(Vector2) var world_size setget _world_size_changed

#func _world_size_changed(size):
#	world_size = size
#	_sync_bounds()

#func _ready():
#	_sync_bounds()
	#get_viewport().connect("size_changed", self, "_sync_bounds")

func set_fade(value, is_immediate = false):
	var target_color = Color(0,0,0,1 if value else 0)
	if is_immediate:
		$CanvasLayer/Black.color = target_color
	else:
		var seq := TweenSequence.new(get_tree())
		seq.append($CanvasLayer/Black, "color", target_color, .25).from_current()
		yield(seq, "finished")
	#seq.append_interval(1)
	#seq.append_callback($Sprite, "set_texture", [load("res://icon2.png")])

var target

func set_target(node):
	target = node	
	
func snap_position():
	global_position = target.get_center_pos()

func _process(delta):
	if target:
		global_position += (target.get_center_pos()-global_position)*delta*5
	
func set_bounds(world_rect):
	limit_left = world_rect.position.x
	limit_right = world_rect.end.x
	limit_top = world_rect.position.y
	limit_bottom = world_rect.end.y
