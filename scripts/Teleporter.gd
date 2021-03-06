class_name Teleporter extends Switch
# "Spawner.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func saved():
	return .saved() + ["scene_name", "path_name"]
	
export var scene_name = ""
export var path_name = ""
export(bool) var flip_h = false
var timer

func start_use():
	.start_use()
	if is_on:
		GameManager.change_scene(scene_name, path_name)

func get_spawn_pos():
	return global_position+Vector2(0,8)
