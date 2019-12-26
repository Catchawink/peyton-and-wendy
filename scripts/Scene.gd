extends Node2D

var player
var pet

# Called when the node enters the scene tree for the first time.
func _ready():
	var spawner = $Spawner
	player = GameManager.player
	pet = GameManager.pet
	player.position = spawner.position
	player.set_flip_h(spawner.flip_h)
	pet.position = player.position
	pet.set_flip_h(spawner.flip_h)
	spawner.visible = false
	yield(get_tree().create_timer(1), "timeout")
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$Line2D.set_point_position(0, pet.position+Vector2(pet.collar_offset.x*pet.get_flip_sign(pet.is_flipped), pet.collar_offset.y))
	#$Line2D.set_point_position(1, player.position+ Vector2(player.handle_offset.x*player.get_flip_sign(player.is_flipped), player.handle_offset.y))
	pass
