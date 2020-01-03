extends Camera2D

#export(Vector2) var world_size setget _world_size_changed

#func _world_size_changed(size):
#	world_size = size
#	_sync_bounds()

func _ready():
	current_pos = global_position
#	_sync_bounds()
	#get_viewport().connect("size_changed", self, "_sync_bounds")

func set_fade(value, is_immediate = false):
	var target_color = Color(0,0,0,1 if value else 0)
	if is_immediate:
		$BlackCanvas/Black.color = target_color
	else:
		var seq := TweenSequence.new(get_tree())
		seq.append($BlackCanvas/Black, "color", target_color, .25).from_current()
		yield(seq, "finished")
	#seq.append_interval(1)
	#seq.append_callback($Sprite, "set_texture", [load("res://icon2.png")])

func set_tint(target_color, duration):
	if duration == 0:
		$TintCanvas/Tint.color = target_color
	else:
		var seq := TweenSequence.new(get_tree())
		seq.append($TintCanvas/Tint, "color", target_color, duration).from_current()
		yield(seq, "finished")
	#seq.append_interval(1)
	#seq.append_callback($Sprite, "set_texture", [load("res://icon2.png")])

var target

func set_target(node):
	target = node	
	
func snap_position():
	current_pos = get_target_pos()
	global_position = current_pos

func get_target_pos():
	var target_pos = Vector2(0,0)
	if target:
		target_pos = target.get_center_pos()
	target_pos = Vector2(center.x if center_x else target_pos.x, center.y if center_y else target_pos.y)
	return target_pos

var current_pos

func _process(delta):
	current_pos += (get_target_pos()-current_pos)*delta*5
	global_position = current_pos
	#global_position = Vector2(int(current_pos.x), int(current_pos.y))
	
var center_x = false
var center_y = false
var center 

func get_resolution():
	return Vector2(ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/height"))
			
func set_bounds(world_rect):
	var resolution = get_resolution()
	center = world_rect.position+world_rect.size/2

	if world_rect.size.x < resolution.x:
		center_x = true
		limit_left = -10000000
		limit_right = 10000000
	else:
		center_x = false
		limit_left = world_rect.position.x
		limit_right = world_rect.end.x
	
	if world_rect.size.y < resolution.y:
		center_y = true
		limit_top = -10000000
		limit_bottom = 10000000
	else:
		center_y = false
		limit_top = world_rect.position.y
		limit_bottom = world_rect.end.y
