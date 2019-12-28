tool extends Interactable
# "Spawner.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var scene_name = ""
export var path_name = ""
export var flip_h = false

var timer

func start_use():
	GameManager.change_scene(scene_name, path_name)
	$AudioStreamPlayer.play()
