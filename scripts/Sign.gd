extends Interactable

export(String, MULTILINE) var text = ""
export(String, MULTILINE) var comment = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func start_use():
	GameManager.lock_input()
	yield(GameManager.player.speak("'"+text+"'"), "completed")
	if len(comment) > 0:
		yield(GameManager.player.speak(comment), "completed")
	GameManager.unlock_input()
