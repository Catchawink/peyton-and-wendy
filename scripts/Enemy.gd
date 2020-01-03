extends "Character.gd"

func init():
	.init()
	run_frames = [7, 12]
	pass

func process_input(delta):
	if not player:
		return
		
	var dist = abs(player.position.x - position.x)

	if dist < width+8:
		can_attack = true
	else:
		can_attack = false
		
	if !is_attacking:
		if player.position.x < position.x:
			$AnimatedSprite.flip_h = true
			if !can_attack and dist > width+8:
				velocity.x += -speed
		if player.position.x > position.x:
			$AnimatedSprite.flip_h = false
			if !can_attack and dist > width+8:
				velocity.x += speed
