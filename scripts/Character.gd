class_name Character extends Stats

export var speed = 70
const GRAVITY = 10
const JUMP_POWER = 160
const FLOOR = Vector2(0, -1)

var run_frames = []
export var attack_frame = 0
var run_volume = 0
var run_pitch = 1

var velocity = Vector2()
var on_ground = false
var crouching = false

var play_run = false
var is_horizontal = false

var is_speaking = false
var is_flipped = false

var override_animation = null

onready var speech_bubble_scene = preload("res://scenes/ui/SpeechBubble.tscn")
var speech_bubble

var can_taunt = false
var taunt_wait_time = 0
var taunt_wait = 2
var taunt_pitch = 1

var can_attack = false
var attack_wait_time = 0
var attack_wait = 2

export var height = 16
export var width = 16
var type

signal died

var is_active = true
var is_physics_active = true
var default_collision_mask
var default_collision_layer

func set_active(value):
	is_active = value
	set_physics_active(is_active)
	visible = is_active
	
func set_physics_active(value):
	is_physics_active = value
	if is_physics_active:
		set_collision_mask(default_collision_mask)
		set_collision_layer(default_collision_layer)
	else:
		set_collision_mask(0)
		set_collision_layer(0)

func set_flip_h(value):
	$AnimatedSprite.set_flip_h(value)

func get_center_pos():
	return global_position+Vector2(0,-height/2)
	
func get_top_pos():
	return global_position+Vector2(0,-height)	
	
func get_bottom_pos():
	return global_position
	
var is_attacking = false

func attack():
	is_attacking = true
	animate_override("attack")
	yield(wait_for_frame(attack_frame), "completed")
	for result in get_front_objects():
		var object = result.collider
		if object != self and object.has_method("damage"):
			object.damage(1)
	yield($AnimatedSprite, "animation_finished")
	is_attacking = false
	pass
	
func damage(amount):
	print(name + " lost " + str(amount) + " heart(s).")
	health -= amount
	
func get_nearby_objects(distance):
	var circle = CircleShape2D.new()
	circle.set_radius(distance)
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(circle)
	params.set_transform(get_transform())  #update position object
	var state = get_world_2d().get_direct_space_state()
	var results = state.intersect_shape(params,100)
	return results
	
var is_initialized = false

func _ready():
	if !is_initialized and GameManager.is_active:
		init()
		is_initialized = true
	
func init():
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
	
func animation_finished():
	pass
	
func speak(text, use_input = true):
	yield(speech_bubble.speak(text, use_input), "completed")
	
func silence():
	speech_bubble.silence()
	
func process_input(delta):
	pass
	
func animate(animation_name, fallback_animation_name = "idle"):
	if not $AnimatedSprite.frames.has_animation(animation_name):
		animation_name = fallback_animation_name
	$AnimatedSprite.play(animation_name)
	update_hand()
	
func look_at(object):
	var dist_x = object.position.x-position.x
	if abs(dist_x) > 8:
		$AnimatedSprite.flip_h = dist_x < 0
	
func get_flip_sign(value=null):
	if value == null:
		value = is_flipped
	return (-1 if value else 1)

func update_hand():
	pass
	
func taunt():
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
	yield(get_tree(), "idle_frame")
	while $AnimatedSprite.frame != frame:
		yield($AnimatedSprite, "frame_changed")
	
func animate_override(animation, auto_stop = true, add_duration = 0):
	animate(animation)
	override_animation = animation
	yield($AnimatedSprite, "animation_finished")
	if override_animation != animation:
		return
	override_animation = null
	
var push = 0
var player
var health = 3
var default_health

func is_dead():
	return health == 0
	
func reset():
	health = default_health

func on_set_player():
	pass
	
func _process(delta):
	if not player:
		var players = get_tree().get_nodes_in_group("players")
		if len(players) > 0:
			player = players[0]
			on_set_player()

func die():
	if is_dead():
		return
	health = 0
	emit_signal("died")
	pass
	
var colliders = []

func get_front_objects():
	var circle = CircleShape2D.new()
	circle.set_radius(4)
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(circle)
	params.set_transform(Transform2D(0, get_center_pos()+Vector2((width/2)*get_flip_sign(), 0)))  #update position object
	var state = get_world_2d().get_direct_space_state()
	var results = state.intersect_shape(params,32)
	return results

func _physics_process(delta):
	if not is_active or !GameManager.is_active:
		velocity = Vector2(0,0)
		return
		
	if !is_dead() and position.y > GameManager.world_rect.end.y:
		die()
		return
			
	if speech_bubble:
		is_speaking = speech_bubble.is_speaking
	
	velocity.x = 0
	
	if can_attack and !is_attacking:
		attack_wait_time += delta
		if attack_wait_time >= attack_wait:
			attack_wait_time = 0
			attack_wait = rand_range(.05, .5)
			attack()
			
	if can_taunt:
		taunt_wait_time += delta
		if taunt_wait_time >= taunt_wait:
			taunt_wait_time = 0
			taunt_wait = rand_range(3, 20)
			taunt()
			
	if !is_dead():
		process_input(delta)
	
	if not override_animation:
		if crouching:
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
	
	if velocity.x != 0:
		$AnimatedSprite.flip_h = (velocity.x < 0)

	is_flipped = $AnimatedSprite.flip_h
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
				collision.collider.apply_impulse(collision.position - collision.collider.position, -collision.normal * push)
				new_colliders.append(collision.collider)
				#collision.collider.apply_central_impulse(-collision.normal * push)
				# Depending on your character's movement speed, adjust push_factor to
				# something between 0 and 1.
		colliders = new_colliders
				
