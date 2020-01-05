class_name Switch extends Interactable

func saved():
	if is_permanent:
		return ["is_on", "is_permanent"]
	return []

export(NodePath) onready var target_a = get_node(target_a) if target_a else null
export(NodePath) onready var target_b = get_node(target_b) if target_b else null
export(NodePath) onready var target_c = get_node(target_c) if target_c else null
#export(NodePath) onready var target_a = get_node(target_a)
#export(Array, NodePath) onready var targets 
#= get_targets(targets)

export var is_on = false
export var is_permanent = false
var is_setting = false
export var stop_is_off = false
export var animate = true
export var stop_sound = false
export(bool) var toggle_on_use = false
signal set_on

func get_targets(target_paths):
	var _targets =  []
	for target_path in target_paths:
		_targets.append(get_node(target_path))
	return _targets

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _load():
	#print(name + " SETTING TO " + str(is_on))
	set_on(is_on, true)
	
func start_use():
	.start_use()
	if toggle_on_use:
		toggle()

func toggle():
	set_on(!is_on)
	
func set_on(value, immediate=false):
	if is_permanent and is_on and !immediate:
		return
		
	is_on = value
	
	if is_permanent and is_on:
		SoundManager.play("clank", -15, .5)
		
	if target_a:
		target_a.set_on(value, immediate)			
	#yield(target_a.set_on(value, immediate), "completed")
	emit_signal("set_on", self, is_on)
	
	if !immediate:
		if has_node("SwitchPlayer"):
			get_node("SwitchPlayer").play()
		
	var animation
	if animate:
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
				if is_on != value:
					return
				animation.play("off")
		else:
			if immediate:
				animation.play("on")
				yield(get_tree().create_timer(0), "timeout")
			else:
				animation.play("off_to_on")
				yield(animation, "animation_finished")
				if is_on != value:
					return
				animation.play("on")
	else:
		yield(get_tree().create_timer(0), "timeout")
	if stop_sound and has_node("SwitchPlayer"):
			get_node("SwitchPlayer").stop()
