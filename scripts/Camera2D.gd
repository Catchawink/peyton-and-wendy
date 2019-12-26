extends Camera2D

export(Vector2) var world_size setget _world_size_changed

func _world_size_changed(size):
	world_size = size
	_sync_bounds()

func _ready():
	_sync_bounds()
	#get_viewport().connect("size_changed", self, "_sync_bounds")

func set_fade(value):
	var seq := TweenSequence.new(get_tree())
	seq.append($Foreground/Black, "color", Color(0,0,0,1 if value else 0), .25).from_current()
	yield(seq, "finished")
	#seq.append_interval(1)
	#seq.append_callback($Sprite, "set_texture", [load("res://icon2.png")])
	
func _sync_bounds():
	return
	var viewport = get_viewport()
	if viewport != null:
		var zoom = get_zoom()
		var scale = Vector2(1 / zoom.x, 1 / zoom.y)

		var resolution = Vector2(ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/width"))
		#var resolution = viewport.size

		if (world_size.x * scale.x) > resolution.x:
			_set_big_margins(world_size.x, resolution.x, scale.x, MARGIN_LEFT, MARGIN_RIGHT)
		else:
			_set_small_margins(world_size.x, resolution.x, scale.x, MARGIN_LEFT, MARGIN_RIGHT)

		if (world_size.y * scale.y) > resolution.y:
			_set_big_margins(world_size.y, resolution.y, scale.y, MARGIN_TOP, MARGIN_BOTTOM)
		else:
			_set_small_margins(world_size.y, resolution.y, scale.y, MARGIN_TOP, MARGIN_BOTTOM)

func _set_big_margins(world_size, screen_size, scale, margin_neg, margin_pos):
	set_limit(margin_neg, 0)

	var diff = (world_size * scale) - screen_size
	diff /= scale
	set_limit(margin_pos, ceil(screen_size + diff))

func _set_small_margins(world_size, screen_size, scale, margin_neg, margin_pos):
	var margin = (screen_size - (world_size * scale)) / 2

	set_limit(margin_neg, floor(-margin / scale))
	set_limit(margin_pos, ceil((margin / scale) - world_size))
