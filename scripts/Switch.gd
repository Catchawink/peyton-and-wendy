extends Interactable

var is_on = true
var is_setting = false

signal set_on

# Called when the node enters the scene tree for the first time.
func _ready():
	set_on(true, true)
	pass # Replace with function body.

func start_use():
	toggle()

func toggle():
	set_on(!is_on)
	
func set_on(value, immediate=false):
	if is_setting:
		return
	is_setting = true
	is_on = value
	if !immediate:
		$SwitchPlayer.play()
	if !is_on:
		if immediate:
			$AnimatedSprite.play("off")
		else:
			$AnimatedSprite.play("on_to_off")
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.play("off")
	else:
		if immediate:
			$AnimatedSprite.play("on")
		else:
			$AnimatedSprite.play("off_to_on")
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.play("on")
	emit_signal("set_on", is_on)
	is_setting = false
