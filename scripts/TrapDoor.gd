extends Teleporter

func start_use():
	yield(set_on(true), "completed")
	GameManager.change_scene(scene_name, path_name)

func get_spawn_pos():
	return global_position+Vector2(0,0)
