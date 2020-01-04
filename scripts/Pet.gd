extends "Character.gd"

var collar_offset = Vector2(4,-6)
var ideal_distance = 0
var max_distance = 10000
const leash_distance = 32
const aware_distance = 48

func init():
	.init()
	ideal_distance = max_distance
	pass
	
func on_set_player():
	player.connect("called", self, "called")
	
func called():
	ideal_distance = 16
	
func is_edge():
	var space_state = get_world_2d().direct_space_state
	var start_position = get_center_pos()+Vector2(get_flip_sign()*8,0)
	var result = space_state.intersect_ray(start_position, start_position+Vector2(0, 16), [self], ~2)
	
	if result.empty():
		return true
	return false
	
func process_input(delta):
	if not player:
		return
	#if Input.is_action_just_pressed("ui_down"):
	#	speak("Greetings!\nHEHEHEH!")
		
	var enemy = null
	
	var results = get_nearby_objects(aware_distance)
	if results:
		for result in results:
			var object = result.collider
			if object.is_in_group("enemies"):
				enemy = object
	
	var dist_x = abs(player.position.x - position.x)
	
	can_taunt = false
	if dist_x <= aware_distance or enemy:
		can_taunt = true
	
	crouching = false
	
	if is_flying:
		z_index = player.z_index + 100
		var dist = player.get_center_pos().distance_to(get_center_pos())
		var dif = (player.get_center_pos()+Vector2(((player.width/2)+(width/2)+4)*-player.get_flip_sign(), height/2)-position)
		if abs(dif.x) > 2 or abs(dif.y) > 2: #dist > 20:
			velocity = dif.normalized()*speed
		else:
			velocity = Vector2(0,0)
		set_target(player)
	else:
		if dist_x > ideal_distance and is_player_visible():
			set_target(player)
			if player.position.x < position.x:
				if !is_edge():
					velocity.x += -speed
			if player.position.x > position.x:
				if !is_edge():
					velocity.x += speed
		else:
			ideal_distance = max_distance
			if enemy:
				crouching = true
				set_target(enemy)
			elif dist_x <= aware_distance:
				crouching = true
				set_target(player)
			else:
				set_target(null)
