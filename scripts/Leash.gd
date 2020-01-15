extends "res://scripts/Item.gd"

func _ready():
	$Line2D.visible = false
	
func select():
	$Line2D.visible = true
	pass
	
func deselect():
	$Line2D.visible = false
	target = null
	pass

var target

func start_use():
	
	#for result in player.get_nearby_objects(32):
	#	var object = result.collider
	#	if object.is_in_group("leashed"):
	#		target = object
			
	#if target:
	pass
	
func stop_use():
	pass
	
func _process(delta):
	#if target != null and player.global_position.distance_to(target.global_position) > 8:
	#	target.linear_velocity =((player.global_position-target.global_position).normalized()*10)
	if !GameManager.is_pet_missing:
		var pet_pos = pet.position+Vector2(pet.collar_offset.x*pet.get_flip_sign(pet.is_flipped), pet.collar_offset.y) # target.global_position#
		var player_pos = player.hand_position
		$Line2D.set_point_position(0, pet_pos-global_position)
		$Line2D.set_point_position(1, player_pos-global_position)
