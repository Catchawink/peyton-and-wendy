extends "Character.gd"

var collar_offset = Vector2(4,-6)
var ideal_distance = 0
var max_distance = 10000
const leash_distance = 32
const aware_distance = 48
var can_fly = true

func init():
	.init()
	ideal_distance = max_distance
	pass
	
func on_set_player():
	player.connect("called", self, "called")
	
func called():
	ideal_distance = 16
	
func is_edge():
	var circle = RectangleShape2D.new()
	circle.set_extents(Vector2(1, 4))
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(circle)
	var pos = get_bottom_pos()+Vector2(get_flip_sign()*(width/2)+2,2)
	params.set_transform(Transform2D(0, pos))
	var state = get_world_2d().get_direct_space_state()
	var results = state.intersect_shape(params)
	
	for result in results:
		if result.collider != self:
			return false
	return true
	"""
	var space_state = get_world_2d().direct_space_state
	var start_position = get_center_pos()+Vector2(get_flip_sign()*8,0)
	var result = space_state.intersect_ray(start_position, start_position+Vector2(0, 16), [self], ~2)
	
	if result.empty():
		return true
	return false
	"""
	
func is_object_visible(object):
	if can_fly:
		return true
	else:
		return .is_object_visible(object)
	
func process_input(delta):
	var input_velocity = Vector2(0,0)
	if not player:
		return input_velocity
	#if Input.is_action_just_pressed("ui_down"):
	#	speak("Greetings!\nHEHEHEH!")
		
	var enemy = null
	var bone = null
	
	var results = get_nearby_objects(128) #aware_distance
	if results:
		for result in results:
			var object = result.collider
			if object.is_in_group("enemies"):
				enemy = object
			if object.is_in_group("items") and object.get_name() == "bone":
				bone = object
	
	
	crouching = false
	
	var _target = null
	if bone and is_object_visible(bone):
		_target = bone
	elif is_object_visible(GameManager.player):
		_target = player
	else:
		_target = enemy
	
	var dist = _target.global_position.distance_to(get_center_pos())
	var dist_x = abs(_target.global_position.x - global_position.x) if _target else 0
	var dist_y = abs(_target.global_position.y - global_position.y) if _target else 0
	
	can_taunt = false
	if dist_x <= aware_distance:
		can_taunt = true
		
	if can_fly:
		if dist > 48 or !get_ground(16) or is_in_object():
			is_flying = true
		elif !is_flying or fly_time > .5:
			is_flying = false
		
	if is_flying:
		z_index = player.z_index + 100
		dist = player.get_center_pos().distance_to(get_center_pos())
		var dif = (player.get_center_pos()+Vector2(((player.width/2)+(width/2)+4)*-player.get_flip_sign(), height/2)-position)
		if abs(dif.x) > 2 or abs(dif.y) > 2: #dist > 20:
			velocity = dif.normalized()*speed
		else:
			velocity = Vector2(0,0)
		set_target(player)
	else:
		set_target(_target)
		if _target:
			if _target.global_position.x < global_position.x:
				if !is_edge() and dist_x > width/2+8:
					input_velocity.x += -speed
			if _target.global_position.x > global_position.x:
				if !is_edge() and dist_x > width/2+8:
					input_velocity.x += speed
		"""
		if dist_x > ideal_distance and is_player_visible():
			set_target(player)
			if player.position.x < position.x:
				if !is_edge():
					input_velocity.x += -speed
			if player.position.x > position.x:
				if !is_edge():
					input_velocity.x += speed
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
		"""
	return input_velocity
