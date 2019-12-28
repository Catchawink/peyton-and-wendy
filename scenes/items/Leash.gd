extends "res://scripts/Item.gd"

func _ready():
	$Line2D.visible = false
	
func select():
	$Line2D.visible = true
	pass
	
func deselect():
	$Line2D.visible = false
	pass

func _process(delta):
	var pet_pos = pet.position+Vector2(pet.collar_offset.x*pet.get_flip_sign(pet.is_flipped), pet.collar_offset.y)
	var player_pos = player.hand_position
	$Line2D.set_point_position(0, pet_pos-global_position)
	$Line2D.set_point_position(1, player_pos-global_position)
