extends "res://scripts/Switch.gd"

func saved():
	return ["is_empty", "item_name"]

export(String) var item_name = ""
var is_empty = false

func set_on(value, immediate=false):
	yield(.set_on(value, immediate), "completed")
	if value and !is_empty:
		GameManager.player.pickup(GameManager.spawn_item(item_name))
		is_empty = true
