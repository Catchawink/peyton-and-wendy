extends KinematicBody2D

const SPEED = 60
const GRAVITY = 10
const JUMP_POWER = 160
const FLOOR = Vector2(0, -1)

const step_volume = -13

var velocity = Vector2()
var on_ground = false
var crouching = false

var run_time = 0
var step_wait = .2
var step_pitch = 1.25

var play_steps = false
var is_horizontal = false

var is_speaking = false
var is_flipped = false

var is_override_animation = false

onready var speech_bubble_scene = preload("res://scenes/ui/SpeechBubble.tscn")
var speech_bubble

func set_flip_h(value):
	$AnimatedSprite.set_flip_h(value)

func get_nearby_objects(distance):
	var circle = CircleShape2D.new()
	circle.set_radius(distance)
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(circle)
	params.set_transform(get_transform())  #update position object
	var state = get_world_2d().get_direct_space_state()
	var results = state.intersect_shape(params)
	return results
	
func _ready():
	speech_bubble = speech_bubble_scene.instance()
	add_child(speech_bubble)
	speech_bubble.set_position(Vector2(13,-25))
	
func speak(text,  use_input = true):
	is_speaking = true
	yield(speech_bubble.speak(text, use_input), "completed")
	is_speaking = false
	
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
	is_override_animation = true
	animate("taunt")
	$TauntPlayer.play()
	var frame_duration = 1/$AnimatedSprite.frames.get_animation_speed($AnimatedSprite.animation)
	while $AnimatedSprite.frame < $AnimatedSprite.frames.get_frame_count($AnimatedSprite.animation)-1:
		yield(get_tree().create_timer(frame_duration), "timeout")
	yield(get_tree().create_timer(frame_duration), "timeout")
	is_override_animation = false
	
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

func _physics_process(delta):
	velocity.x = 0
	
	process_input(delta)
		
	if play_steps:
		if velocity.x != 0 and on_ground:
			run_time += delta
			if run_time >= step_wait:
				$StepPlayer.volume_db = rand_range(step_volume-5, step_volume+5)
				$StepPlayer.pitch_scale = rand_range(step_pitch-.05, step_pitch+.05)
				$StepPlayer.play()
				run_time = 0
		else:
			run_time = step_wait
	
	if not is_override_animation:
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
			#collision.collider.apply_impulse(collision.position - collision.collider.position, -collision.normal * push)
			collision.collider.apply_central_impulse(-collision.normal * push)
			# Depending on your character's movement speed, adjust push_factor to
			# something between 0 and 1.
				
