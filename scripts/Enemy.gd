extends "Character.gd"

func init():
	.init()
	run_frames = [7, 12]
	pass

func process_input(delta):
	var input_velocity = Vector2(0,0)
	if not player or !is_object_visible(GameManager.player):
		return input_velocity
		
	var x_dist = abs(player.position.x - position.x)

	if x_dist < (width/2)+8:
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
			if x_dist > (width/2):
				input_velocity.x += -speed
		if player.position.x > position.x:
			$AnimatedSprite.flip_h = false
			if x_dist > (width/2):
				input_velocity.x += speed
	return input_velocity
