extends "Character.gd"

func _ready():
	pass

func process_input(delta):
	if not player:
		return
		
	var dist = abs(player.position.x - position.x)

	if dist > 32:
		if player.position.x < position.x:
			velocity.x += -SPEED
			
		if player.position.x > position.x:
			velocity.x += SPEED
