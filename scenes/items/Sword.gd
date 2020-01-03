extends "res://scripts/Item.gd"


func start_use():
	GameManager.player.attack()
	pass
	
func stop_use():
	pass
