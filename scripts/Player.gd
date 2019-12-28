extends "Character.gd"

signal called
var animations = {}
var replace_color = Color(.153, .125, .204)
var handle_offset = Vector2(4,10)
var is_input_locked = false

func init():
	.init()
	play_steps = true
	push = 50
	GameManager.inventory.connect("item_added", self, "item_added")
	
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
	if hand_position == Vector2(-1,-1):
		$Hand.visible = false
	else:
		$Hand.visible = true
		hand_position += Vector2(2,1)+$AnimatedSprite.offset
		$Hand.position = Vector2(hand_position.x*get_flip_sign(is_flipped), hand_position.y)
	#$Hand.scale = Vector2(get_flip_sign(is_flipped), 1)
	for item in $Hand.get_children():
		item.get_node("Sprite").set_flip_h(is_flipped)
		item.position = Vector2(item.hand_offset.x*get_flip_sign(is_flipped), item.hand_offset.y)
	
var pickup_item

func pickup(item):
	pickup_item = SaveManager.copy(item)
	item.set_active(false)
	
	pickup_item.set_physics_active(false)
	pickup_item.get_parent().remove_child(pickup_item)
	add_child(pickup_item)
	$PickupPlayer.play()
	
	if !is_speaking:
		yield(animate_override("pickup", .5), "completed")

	GameManager.inventory.add_item(item)
	pickup_item = null
	
func item_added(item):
	item.set_physics_active(false)
	item.get_parent().remove_child(item)
	$Hand.add_child(item)
	update_hand()

var using_inventory = false
var interactables = []

func register(interactable):
	interactables.append(interactable)

func deregister(interactable):
	interactables.erase(interactable)
	
func get_interactable():
	var max_priority = -1
	var current_interactable
	for interactable in interactables:
		if interactable.priority > max_priority:
			max_priority = interactable.priority
			current_interactable = interactable
	return current_interactable
	
func process_input(delta):
	if is_input_locked:
		return
		
	if Input.is_action_just_pressed("ui_examine"):
		var interactable = get_interactable()
		if interactable:
			interactable.start_use()
		else:
			GameManager.inventory.start_use()
	if Input.is_action_just_released("ui_examine"):
		var interactable = get_interactable()
		if interactable:
			interactable.start_use()
		else:
			GameManager.inventory.stop_use()	
			
	if Input.is_action_just_pressed("ui_inventory"):
		using_inventory = !using_inventory
		GameManager.inventory.set_active(using_inventory)
		
	#if Input.is_action_just_released("ui_inventory"):
	#	using_inventory = false
	#	GameManager.inventory.set_active(using_inventory)
		
	if using_inventory:
		if Input.is_action_just_pressed("ui_right"):
			GameManager.inventory.select_right()
		if Input.is_action_just_pressed("ui_left"):
			GameManager.inventory.select_left()
		return
		
	update_hand()
	
	if pickup_item:
		pickup_item.global_position = get_top_pos() + Vector2(0, -11)
		pickup_item.rotation_degrees = 0
		return
	else:
		var results = get_nearby_objects(16)
		if results:
			for result in results:
				var object = result.collider
				if object.is_in_group("items"):
					var dist = get_center_pos().distance_to(object.global_position)
					if dist < 8:
						pickup(object)
					else:
						object.position += (get_center_pos()-object.position).normalized()*delta*100
	
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
		$JumpPlayer.play()
