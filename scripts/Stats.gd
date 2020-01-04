class_name Stats extends KinematicBody2D

onready var speech_bubble_scene = preload("res://scenes/ui/SpeechBubble.tscn")

var is_damaging = false
export var health = 3
var default_health
var is_dead = false

var override_animation = null
	
var is_initialized = false
var is_animated = false

func _ready():
	if !is_initialized and GameManager.is_active:
		init()
		is_initialized = true
	
func init():
	if has_node("AnimatedSprite"):
		is_animated = true
		
func die():
	if is_dead:
		return
	is_dead = true
	health = 0
	#print(name + ", " + str(health))
	if is_animated:
		yield(animate_override("die"), "completed")
	emit_signal("died")
	visible = false
	pass
	
func animate(animation_name, fallback_animation_name = "idle"):
	if not $AnimatedSprite.frames.has_animation(animation_name):
		animation_name = fallback_animation_name
	$AnimatedSprite.play(animation_name)


func animate_override(animation, auto_stop = true, add_duration = 0):
	animate(animation)
	override_animation = animation
	yield($AnimatedSprite, "animation_finished")
	if override_animation != animation:
		return
	override_animation = null
	
func damage(amount):
	if is_damaging or is_dead:
		return
	is_damaging = true
	#print(name + " lost " + str(amount) + " heart(s).")
	health = max(health-1, 0)
	if health == 0:
		die()
	elif is_animated:
		yield(animate_override("hit"), "completed")
	is_damaging = false
