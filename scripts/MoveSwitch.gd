extends Switch

export(Array, Vector2) var positions = []
export(bool) var ping_pong = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var last_position = -1
var default_pos
var target_pos
var speed = 16
var current_sequence

func _ready():
	positions.insert(0, Vector2(0,0))
	default_pos = global_position
	target_pos = default_pos

var is_running = false
var is_reversing = false
var target_index = 0

func _physics_process(delta):
	if !is_running:
		return
	if global_position.distance_to(target_pos) > 1:
		global_position += (target_pos-global_position).normalized()*delta*speed
	else:
		global_position = target_pos
		var is_start = target_index == 0
		var is_end = (target_index == len(positions)-1)
		if ping_pong and is_end and !is_reversing:
			is_reversing = true
		if ping_pong and is_start and is_reversing:
			is_reversing = false
			
		if is_end and !is_reversing:
			is_running = false
		elif is_start and is_reversing:
			is_running = false
		elif is_reversing:
			set_target_index(target_index-1)
		else:
			set_target_index(target_index+1)

func set_target_index(index):
	target_index = index
	target_pos = default_pos+(positions[target_index]*16)
	
func set_on(value, immediate=false):
	yield(.set_on(value, immediate), "completed")
	
	if ping_pong:
		is_running = is_on
		is_reversing = false
	else:
		is_running = true
		is_reversing = !is_on
		while is_running:
			yield(get_tree().create_timer(.1), "timeout")
	#	set_linear_velocity((target_pos - global_position).normalized()*20)
