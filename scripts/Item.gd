class_name Item extends RigidBody2D

func saved():
	return ["is_active", "comment"]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var hand_offset : Vector2
export var use_hand = true
export var is_weapon = false
export(bool) var drop_on_use = false
export(String, MULTILINE) var comment = ""

var is_active = true
var is_using = false

var default_gravity_scale
var default_collision_mask
var default_collision_layer

var player
var pet

func get_name():
	return filename.get_file().replace("."+filename.get_extension(), "").to_lower()

func select():
	pass
	
func deselect():
	pass
	
func start_use():
	if drop_on_use:
		GameManager.inventory.remove_item(self, false)
	pass
	
func stop_use():
	pass
	
func on_visible_changed(visible):
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pet = GameManager.pet
	player = GameManager.player
	default_gravity_scale = get_gravity_scale()
	default_collision_mask = get_collision_mask()
	default_collision_layer = get_collision_layer()
	pass # Replace with function body.

func _load():
	print(name + ", " + str(is_active))
	set_active(is_active)
	
func set_physics_active(value):
	$CollisionShape2D.disabled = !value
	if value:
		set_collision_mask(default_collision_mask)
		set_collision_layer(default_collision_layer)
		set_gravity_scale(default_gravity_scale)
		set_can_sleep(false)
		set_sleeping(false)
	else:
		set_gravity_scale(0)
		set_collision_mask(0)
		set_collision_layer(0)
		set_can_sleep(true)
		set_sleeping(true)
		
func set_active(value):
	is_active = value
	set_physics_active(value)
	visible = value
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
