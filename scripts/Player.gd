extends "Character.gd"

signal called
var animations = {}
var replace_color = Color(.153, .125, .204)
var handle_offset = Vector2(4,10)

func _ready():
	._ready()
	play_steps = true
	push = 50
	$AnimatedSprite.connect("frame_changed", self, "update_hand")
	for animation in $AnimatedSprite.frames.get_animation_names():
		var frames = {}
		for frame_index in range(0, $AnimatedSprite.frames.get_frame_count(animation)):
			frames[frame_index] = fliter_frame(animation, frame_index)
		animations[animation] = frames

var last_animation = ""

const FLOAT_EPSILON = 0.00001

static func compare_floats(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon
	
func fliter_frame(animation, frame_index):
	var frame = $AnimatedSprite.frames.get_frame(animation, frame_index)
	var image = frame.get_data()
	image.lock()
	var frame_pos = Vector2(-1,-1)
	for x in range(0, image.get_width()):
		for y in range(0, image.get_height()):
			var pixel = image.get_pixel(x, y)
			if compare_floats(pixel.r, 1) and compare_floats(pixel.g, 0) and compare_floats(pixel.b, 1):
				frame_pos = Vector2(x,y)
				image.set_pixel(x,y,replace_color)
	if frame_pos != Vector2(-1,-1):
		var new_frame = ImageTexture.new()
		new_frame.create(image.get_width(),image.get_height(), image.get_format(), 0)
		new_frame.set_data(image)
		$AnimatedSprite.frames.set_frame(animation, frame_index, new_frame)
	image.unlock()
	return frame_pos

func _process(delta):
	if $AnimatedSprite.animation != last_animation:
		animation_changed($AnimatedSprite.animation)
		last_animation = $AnimatedSprite.animation
	pass

func animation_changed(animation):
	update_hand()
	if animation == "call":
		speak("Wendy!", false)
		emit_signal("called")

func update_hand():
	var hand_position = animations[$AnimatedSprite.animation][$AnimatedSprite.frame]
	hand_position += Vector2(2,1)+$AnimatedSprite.offset
	$Hand.position = Vector2(hand_position.x*get_flip_sign(is_flipped), hand_position.y)
	$Hand.scale = Vector2(get_flip_sign(is_flipped), 1)
	
func process_input(delta):
	
	var results = get_nearby_objects(64)
	if results:
		for result in results:
			var object = result.collider
			if object.is_in_group("items"):
				object.position += (position-object.position)*delta*2
				
	update_hand()
	
	if Input.is_action_pressed("ui_down") and on_ground:
		crouching = true
	else:
		crouching = false

	is_horizontal = false
	
	if Input.is_action_pressed("ui_right"):
		is_horizontal = true
		if not crouching:
			velocity.x += SPEED
		$AnimatedSprite.flip_h = false
	
	if Input.is_action_pressed("ui_left"):
		is_horizontal = true
		if not crouching:
			velocity.x += -SPEED
		$AnimatedSprite.flip_h = true
		
	if Input.is_action_pressed("ui_up") and on_ground:
		velocity.y = -JUMP_POWER
