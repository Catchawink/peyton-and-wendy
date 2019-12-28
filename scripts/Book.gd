extends "res://scripts/Item.gd"

export(String, MULTILINE) var text = ""

func saved():
	return .saved()+["text"]
	
func start_use():
	GameManager.reader.read(text)
	
func stop_use():
	GameManager.reader.clear()
