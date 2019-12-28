extends "Character.gd"

var collar_offset = Vector2(4,-7)
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

func is_player_visible():
	var y_dist = abs(player.position.y - position.y)
	if y_dist > 8:
		return false
		
	var space_state = get_world_2d().direct_space_state
	var start_position = global_position+Vector2(0,collar_offset.y)
	var result = space_state.intersect_ray(start_position, Vector2(player.global_position.x, start_position.y), [self], ~2)
	
	if not result.empty():
		var hit_pos = result.position
		if result.collider.is_in_group("players"):
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
	if dist_x > ideal_distance and is_player_visible():
		if player.position.x < position.x:
			velocity.x += -SPEED
		if player.position.x > position.x:
			velocity.x += SPEED
	else:
		ideal_distance = max_distance
		if enemy:
			crouching = true
			look_at(enemy)
		elif dist_x <= aware_distance:
			crouching = true
			look_at(player)
