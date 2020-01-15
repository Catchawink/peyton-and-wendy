class_name Character extends Stats

export var speed = 70
const GRAVITY = 10
const JUMP_POWER = 160
const FLOOR = Vector2(0, -1)

var run_frames = []
export var attack_frame = 0
var run_volume = 0
var run_pitch = 1

var is_climbing = false

var velocity = Vector2()
var on_ground = false
var crouching = false

var play_run = false
var is_horizontal = false

var is_speaking = false
var is_flipped = false

var speech_bubble

var can_taunt = false
var taunt_wait_time = 0
var taunt_wait = 2
var taunt_pitch = 1

var can_attack = false
var attack_wait_time = 0
var attack_wait = 0

export var height = 16
export var width = 16
var type
var default_z_index

signal died

var is_active = true
var is_physics_active = true
var default_collision_mask
var default_collision_layer
export(bool) var use_gravity = true

var is_flying = false

func set_active(value):
	is_active = value
	visible = is_active
	
func set_physics_active(value):
	is_physics_active = value
		
func set_collisions_active(value):
	if value:
		set_collision_mask(default_collision_mask)
		set_collision_layer(default_collision_layer)
	else:
		set_collision_mask(0)
		set_collision_layer(0)

func set_flip_h(value):
	$AnimatedSprite.set_flip_h(value)

func get_forward_pos(offset=0):
	return global_position+Vector2(((width/2)+offset)*get_flip_sign(),-height/2)
	
func get_center_pos():
	return global_position+Vector2(0,-height/2)
	
func get_top_pos():
	return global_position+Vector2(0,-height)	
	
func get_bottom_pos():
	return global_position
	
var is_attacking = false

func is_in_object():
	return len(get_nearby_objects(1, ~2)) > 0
	
func start_flying():
	is_flying = true
	z_index = 100
	
func stop_flying():
	is_flying = false
	z_index = default_z_index

func sneeze():
	yield(animate_override("sneeze"), "completed")
	
func attack():
	if is_damaging or is_dead:
		return
	is_attacking = true
	animate_override("attack")
	if !yield(wait_for_frame(attack_frame), "completed"):
		is_attacking = false
		return
	for result in get_front_objects():
		var object = result.collider
		if object != self and object.has_method("damage"):
			object.damage(1)
	yield($AnimatedSprite, "animation_finished")
	is_attacking = false
	pass
	
func get_nearby_objects(distance, mask=~0):
	var circle = CircleShape2D.new()
	circle.set_radius(distance)
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(circle)
	params.set_collision_layer(mask)
	params.set_transform(Transform2D(0, get_center_pos()))  #update position object
	var state = get_world_2d().get_direct_space_state()
	var results = state.intersect_shape(params,100)
	return results

var is_sitting = false
var is_sleeping = false
var is_blinking = false
var fly_time = 0


func set_sleeping(value):
	is_sleeping = value
	
func set_blinking(value):
	is_blinking = value
	
func set_sitting(value, is_immediate=false):
	is_sitting = value
	if !is_immediate:
		if is_sitting:
			yield(animate_override("sit_down"), "completed")
		else:
			yield(animate_override("sit_up"), "completed")
	
func is_wall():
	var space_state = get_world_2d().direct_space_state
	var end_position = get_center_pos()+Vector2(get_flip_sign()*(width/2+1),0)
	var result = space_state.intersect_ray(get_center_pos(), end_position, [self], ~2)
	
	if result.empty():
		return false
	return true


func init():
	.init()
	default_z_index = z_index
	default_collision_mask = get_collision_mask()
	default_collision_layer = get_collision_layer()
	$AnimatedSprite.connect("animation_finished", self, "animation_finished")
	$AnimatedSprite.connect("frame_changed", self, "frame_changed")
	run_volume = $StepPlayer.volume_db
	run_pitch = $StepPlayer.pitch_scale
	default_health = health
	taunt_pitch = $TauntPlayer.pitch_scale
	speech_bubble = speech_bubble_scene.instance()
	add_child(speech_bubble)
	speech_bubble.set_global_position(get_top_pos()+Vector2(14,-7))
	animate("idle")
	
var is_input_locked = false

func set_lock_input(value):
	is_input_locked = value

func animation_finished():
	pass
	
func raise():
	yield(animate_override("raise"), "completed")
	
func speak(text, use_input = true, interrupt=false, line_limit=-1, accelerate=false):
	yield(speech_bubble.speak(text, use_input, interrupt, line_limit, accelerate), "completed")
	
func silence():
	speech_bubble.silence()
	
func get_rect():
	return Rect2(get_top_pos()+Vector2(-width/2, 0), Vector2(width, height))
	
func is_visible():
	return GameManager.get_camera_rect().intersects(get_rect())
	
func process_input(delta):
	return Vector2(0,0)
	
var target

func set_target(object):
	target = object
	
func get_flip_sign(value=null):
	if value == null:
		value = is_flipped
	return (-1 if value else 1)
	
func taunt(is_muted=false):
	if !is_muted:
		$TauntPlayer.pitch_scale = rand_range(taunt_pitch-.1, taunt_pitch+.1)
		$TauntPlayer.play()
	yield(animate_override("taunt"), "completed")

func cancel_override():
	override_animation = null
	
func frame_changed():
	if $AnimatedSprite.animation == "run" and run_frames.has($AnimatedSprite.frame):
		$StepPlayer.volume_db = rand_range(run_volume-5, run_volume+5)
		$StepPlayer.pitch_scale = rand_range(run_pitch-.05, run_pitch+.05)
		$StepPlayer.play()
	pass
	
func wait_for_frame(frame):
	var animation = $AnimatedSprite.animation
	yield(get_tree(), "idle_frame")
	while $AnimatedSprite.frame != frame and $AnimatedSprite.animation == animation:
		yield(get_tree(), "idle_frame")
	return $AnimatedSprite.animation == animation
	
var push = 0
var player

func on_set_player():
	pass
	
func _process(delta):
	if not player:
		var players = get_tree().get_nodes_in_group("players")
		if len(players) > 0:
			player = players[0]
			on_set_player()

var colliders = []

func get_front_objects():
	var circle = CircleShape2D.new()
	circle.set_radius(8)
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(circle)
	params.set_transform(Transform2D(0, get_center_pos()+Vector2((width/2+8)*get_flip_sign(), 0)))  #update position object
	var state = get_world_2d().get_direct_space_state()
	var results = state.intersect_shape(params,32)
	return results
	
var jump_started = false

func jump():
	jump_started = true
	velocity.y = -JUMP_POWER
	$JumpPlayer.play()
	yield(get_tree().create_timer(.25), "timeout")
	jump_started = false
	
func start_climbing():
	is_climbing = true
	velocity.y = 0

func stop_climbing():
	is_climbing = false
	velocity.y = 0
	
func get_ground(distance=2):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(get_bottom_pos(), get_bottom_pos()+Vector2(0,distance), [self], ~2)
	
	if not result.empty():
		return result.collider
	return null
	
var move_to_pos = null
func move_to(pos):
	move_to_pos = pos
	
func is_object_visible(object):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(get_top_pos(), object.global_position, [self], ~2)
	
	if not result.empty():
		var hit_pos = result.position
		if result.collider == object:
			return true
	return false
	
var ground
var last_ground_pos

func _physics_process(delta):
	
	if is_flying:
		fly_time += delta
	else:
		fly_time = 0
		
	if is_flying or is_climbing:
		set_collisions_active(false)
	else:
		set_collisions_active(is_active)
	set_physics_active(is_active)

	if not is_active or !GameManager.is_active:
		velocity = Vector2(0,0)
		return
		
	if !is_dead and position.y > GameManager.world_rect.end.y:
		die()
		return
			
	if speech_bubble:
		is_speaking = speech_bubble.is_speaking
	
	velocity.x = 0
			
	if can_taunt:
		taunt_wait_time += delta
		if taunt_wait_time >= taunt_wait:
			taunt_wait_time = 0
			taunt_wait = rand_range(3, 20)
			taunt()
		
	var input_velocity = Vector2(0,0)
	if move_to_pos != null:
		var x_dif = move_to_pos.x-global_position.x
		if x_dif > 0:
			input_velocity.x = speed
		elif x_dif < 0:
			input_velocity.x = -speed
		else:
			input_velocity.x = 0
		input_velocity.y = 0
	elif !is_dead and !is_damaging and !is_sitting and !is_input_locked:
		input_velocity = process_input(delta)
		
	var new_ground = get_ground()
	if ground != new_ground:
		ground = new_ground
		last_ground_pos = null
		
	if ground and ground.is_in_group("platforms") and last_ground_pos != null:
		var move_dif = ground.global_position-last_ground_pos
		global_position += move_dif
		
	if ground:
		last_ground_pos = ground.global_position
		
	if on_ground and input_velocity.y == 0 and !is_climbing and !jump_started:
		velocity.y = get_floor_velocity().y
	
	if is_climbing:
		velocity.y = 0
		
	velocity += input_velocity
	
	if not override_animation:
		if is_dead:
			animate("dead")
		elif is_sitting:
			if is_sleeping:
				animate("sit_sleep")
			elif is_blinking:
				animate("sit_blink")
			else:
				animate("sit")
		elif is_flying:
			animate("fly")
		elif is_climbing:
			if velocity.y != 0:
				animate("climb")
			else:
				animate("hang")
		elif crouching:
			if is_horizontal:
				animate("call")
			else:
				animate("crouch")
		elif on_ground:
			if velocity.x != 0:
				animate("run")
			else:
				animate("idle")
		else:
			if velocity.y < 0:
				animate("jump")
			else:
				animate("fall")
	
	if target:
		var dist_x = target.global_position.x-global_position.x
		if abs(dist_x) > 2:
			$AnimatedSprite.flip_h = dist_x < 0
	elif velocity.x != 0:
		$AnimatedSprite.flip_h = (velocity.x < 0)

	is_flipped = $AnimatedSprite.flip_h
	if use_gravity and !is_climbing and !is_flying:
		velocity.y += GRAVITY
	
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
		
	if is_physics_active:
		velocity = move_and_slide(velocity, FLOOR, false, 4, PI/4, false)
		
		var new_colliders = []
		for index in get_slide_count():
			var collision = get_slide_collision(index)
			if collision.collider.is_in_group("bodies"):
				if not collision.collider in colliders:
					collision.collider.emit_signal("body_entered", self)
				#collision.collider.apply_impulse(collision.position - collision.collider.position, -collision.normal * push)
				new_colliders.append(collision.collider)
				collision.collider.apply_central_impulse(-collision.normal * push)
				# Depending on your character's movement speed, adjust push_factor to
				# something between 0 and 1.
		colliders = new_colliders
