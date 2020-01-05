extends Switch

func saved():
	if respawn:
		return ["item_name"]
	else:
		return ["is_empty", "item_name"]

export(String) var item_name = ""
export(bool) var respawn = false
var is_empty = false

func set_on(value, immediate=false):
	yield(.set_on(value, immediate), "completed")
	if value and !is_empty:
		GameManager.pickup(item_name)
		is_empty = true
