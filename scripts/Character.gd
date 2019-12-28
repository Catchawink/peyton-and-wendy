extends KinematicBody2D

const SPEED = 70
const GRAVITY = 10
const JUMP_POWER = 160
const FLOOR = Vector2(0, -1)

var step_time = 0
var step_wait = .2
const step_volume = -25
var step_pitch = 1

var velocity = Vector2()
var on_ground = false
var crouching = false

var play_steps = false
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

export var height = 16
var type

signal died

func set_flip_h(value):
	$AnimatedSprite.set_flip_h(value)

func get_center_pos():
	return global_position+Vector2(0,-height/2)
	
func get_top_pos():
	return global_position+Vector2(0,-height)	
	
func get_nearby_objects(distance):
	var circle = CircleShape2D.new()
	circle.set_radius(distance)
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(circle)
	params.set_transform(get_transform())  #update position object
	var state = get_world_2d().get_direct_space_state()
	var results = state.intersect_shape(params)
	return results
	
var is_initialized = false

func _ready():
	if !is_initialized:
		init()
		is_initialized = true
	
func init():
	default_health = health
	taunt_pitch = $TauntPlayer.pitch_scale
	speech_bubble = speech_bubble_scene.instance()
	add_child(speech_bubble)
	speech_bubble.set_global_position(get_top_pos()+Vector2(13,-9))
	
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
	
func get_flip_sign(value):
	return (-1 if value else 1)

func update_hand():
	pass
	
func taunt():
	$TauntPlayer.pitch_scale = rand_range(taunt_pitch-.1, taunt_pitch+.1)
	$TauntPlayer.play()
	yield(animate_override("taunt"), "completed")

func cancel_override():
	override_animation = null
	
func animate_override(animation, auto_stop = true, add_duration = 0):
	animate(animation)
	override_animation = animation
	if not auto_stop:
		return
	var frame_duration = 1/$AnimatedSprite.frames.get_animation_speed($AnimatedSprite.animation)
	while $AnimatedSprite.frame < $AnimatedSprite.frames.get_frame_count($AnimatedSprite.animation)-1:
		yield(get_tree().create_timer(frame_duration), "timeout")
		if override_animation != animation:
			return
	yield(get_tree().create_timer(frame_duration+add_duration), "timeout")
	if override_animation != animation:
		return
	override_animation = null
	
var push = 0
var player
var health = 3
var default_health

func is_dead():
	return health == 0

func on_set_player():
	pass
	
func _process(delta):
	if not player:
		var players = get_tree().get_nodes_in_group("players")
		if len(players) > 0:
			player = players[0]
			on_set_player()

func die():
	health = 0
	emit_signal("died")
	pass

func _physics_process(delta):
	if !is_dead() and position.y > GameManager.world_rect.end.y:
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
			
	if !is_dead():
		process_input(delta)
		
	if play_steps:
		if velocity.x != 0 and on_ground:
			step_time += delta
			if step_time >= step_wait:
				$StepPlayer.volume_db = rand_range(step_volume-5, step_volume+5)
				$StepPlayer.pitch_scale = rand_range(step_pitch-.05, step_pitch+.05)
				$StepPlayer.play()
				step_time = 0
		else:
			step_time = step_wait
	
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
		
	velocity = move_and_slide(velocity, FLOOR, false, 4, PI/4, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_impulse(collision.position - collision.collider.position, -collision.normal * push)
			#collision.collider.apply_central_impulse(-collision.normal * push)
			# Depending on your character's movement speed, adjust push_factor to
			# something between 0 and 1.
				
