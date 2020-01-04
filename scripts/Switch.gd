class_name Switch extends Interactable

export(NodePath) onready var target_a = get_node(target_a) if target_a else null
export(NodePath) onready var target_b = get_node(target_b) if target_b else null
export(NodePath) onready var target_c = get_node(target_c) if target_c else null
#export(NodePath) onready var target_a = get_node(target_a)
#export(Array, NodePath) onready var targets 
#= get_targets(targets)

export var is_on = false
var is_setting = false
export var stop_is_off = false
export var animate = true
signal set_on

func get_targets(target_paths):
	var _targets =  []
	for target_path in target_paths:
		_targets.append(get_node(target_path))
	return _targets

# Called when the node enters the scene tree for the first time.
func _ready():
	set_on(is_on, true)
	pass # Replace with function body.

func start_use():
	toggle()

func toggle():
	set_on(!is_on)
	
func set_on(value, immediate=false):
	if is_setting:
		return
	is_setting = true
	is_on = value
	if !animate:
		is_setting = false
		return
	if !immediate:
		if has_node("SwitchPlayer"):
			get_node("SwitchPlayer").play()
		
	var animation
	if has_node("AnimatedSprite"):
		animation = get_node("AnimatedSprite")
	if has_node("AnimationPlayer"):
		animation = get_node("AnimationPlayer")
		
	if animation:
		if animation is AnimationPlayer:
			immediate = true
			
		if !is_on:
			if immediate:
				if animation is AnimationPlayer and stop_is_off:
					animation.stop(false)
				else:
					animation.play("off")
					yield(get_tree().create_timer(0), "timeout")
			else:
				animation.play("on_to_off")
				yield(animation, "animation_finished")
				animation.play("off")
		else:
			if immediate:
				animation.play("on")
				yield(get_tree().create_timer(0), "timeout")
			else:
				animation.play("off_to_on")
				yield(animation, "animation_finished")
				animation.play("on")
	else:
		yield(get_tree().create_timer(0), "timeout")
	
	if target_a:
		target_a.set_on(value, immediate)			
	#yield(target_a.set_on(value, immediate), "completed")
	emit_signal("set_on", is_on)
	is_setting = false
