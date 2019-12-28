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

func get_target_pos():
	if target:
		return target.get_center_pos()
	return Vector2(0,0)

func _process(delta):
	global_position = get_target_pos()
	global_position = Vector2(center.x if center_x else global_position.x, center.y if center_y else global_position.y)
	global_position = Vector2(int(global_position.x), int(global_position.y))
	
var center_x = false
var center_y = false
var center 

func set_bounds(world_rect):
	var resolution = Vector2(ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/width"))
			
	center = world_rect.position+world_rect.size/2

	if world_rect.size.x < resolution.x:
		center_x = true
	else:
		center_x = false
		limit_left = world_rect.position.x
		limit_right = world_rect.end.x
	
	if world_rect.size.y < resolution.y:
		center_y = true
	else:
		center_y = false
		limit_top = world_rect.position.y
		limit_bottom = world_rect.end.y

