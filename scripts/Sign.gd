extends Interactable

export(String, MULTILINE) var text = ""
export(String, MULTILINE) var comment = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func start_use():
	GameManager.set_lock_input(true)
	yield(GameManager.player.speak("'"+text+"'"), "completed")
	if len(comment) > 0:
		yield(GameManager.player.speak(comment), "completed")
	GameManager.set_lock_input(false)
