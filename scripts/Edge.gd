tool extends Teleporter

func _process(delta):
	if has_node("AnimatedSprite"):
		get_node("AnimatedSprite").set_flip_h(!flip_h)
		
func get_spawn_pos():
	return global_position+Vector2(16*(-1 if flip_h else 1), 16)
