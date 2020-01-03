tool extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Texture) var ladder_top
export(Texture) var ladder_middle
export(Texture) var ladder_bottom

var is_top = false
var is_bottom = false
var is_middle = true
		
# Called when the node enters the scene tree for the first time.
func _ready():
	update_order()
	pass # Replace with function body.

const height = 16
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		update_order()
	pass
	
func update_order():
	var parent = get_parent()

	var is_by_top = false
	var is_by_bottom = false
	
	if parent:
		for child in parent.get_children():
			if child.get_class() == self.get_class():
				if child == self:
					continue
				var dif = child.position-position
				if dif.x == 0:
					if dif.y == height:
						is_by_bottom = true
					if dif.y == -height:
						is_by_top = true
						
	if is_by_top and !is_by_bottom:
		is_bottom = true
		$Sprite.set_texture(ladder_bottom)
	elif is_by_bottom and !is_by_top:
		is_top = true
		$Sprite.set_texture(ladder_top)
	else:
		is_middle = true
		$Sprite.set_texture(ladder_middle)
