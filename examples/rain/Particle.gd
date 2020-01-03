extends Node2D

#onready var lifetime = get_node(get_parent().tracker_name).lifetime
var lifetime = 5
#export (Gradient) var gradient

func _enter_tree():
	pass
	
func _ready():
	#connect("body_entered", self, "body_entered")
	## align the sparks direction with its velocity
#	update_rotation()
	## scale the tail of the sprite based on its velocity
	#$SparkSprite/Tail.scale = Vector2(1, min( 4, linear_velocity.length() / 100 ) )
	rotation_degrees = -150
	pass

func body_entered(var node):
	queue_free()
	pass
	
func update_rotation():
	#$Sprite.global_rotation = linear_velocity.angle()
	pass
	#$Sprite.global_rotation_degrees += 90
	
func _process(delta):
	var angle = rotation- PI/2.0
	position += Vector2(cos(angle), sin(angle))*delta*200
	
func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
#	update_rotation()
	pass
	## align the sparks direction with its velocity
	#update_rotation()
	## scale the tail of the sprite based on its velocity
	#$SparkSprite/Tail.scale = Vector2(1, min( 4, linear_velocity.length() / 100 ) )
