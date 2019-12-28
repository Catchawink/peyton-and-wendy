tool extends Label

func _process(delta):
	set_text(get_parent().text)
	set_align(get_parent().get_align())
	set_valign(get_parent().get_valign())
	set_size(get_parent().get_size())
	#set_position(Vector2(0,0))
