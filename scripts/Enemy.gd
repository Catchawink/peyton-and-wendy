extends "Character.gd"

func init():
	.init()
	run_frames = [7, 12]
	pass

func process_input(delta):
	if not player or !is_player_visible():
		return
		
	var x_dist = abs(player.position.x - position.x)

	if x_dist < 32 and x_dist < (width/2)+32:
		can_attack = true
	else:
		can_attack = false
		
	if can_attack and !is_attacking:
		attack_wait_time += delta
		if attack_wait_time >= attack_wait:
			attack_wait_time = 0
			attack_wait = rand_range(.05, .25)
			attack()
		
	if !is_attacking:
		if player.position.x < position.x:
			$AnimatedSprite.flip_h = true
			if !can_attack and x_dist > width+8:
				velocity.x += -speed
		if player.position.x > position.x:
			$AnimatedSprite.flip_h = false
			if !can_attack and x_dist > width+8:
				velocity.x += speed
