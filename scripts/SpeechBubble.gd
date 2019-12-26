tool extends Control

var arrow
func _ready():
	$Label.connect("resized", self, "update_dimensions")
	arrow = $Label/MarginContainer/Arrow
	clear()
	
var current_id = 0

func clear():
	$Label.set_text("")
	self.visible = false
	arrow.visible = false

func speak(text, use_input = true):
	arrow.visible = false
	text = text.to_upper()
	self.visible = true
	var display_text = ""
	var id = current_id+1
	current_id = id
	for text_char in text:
		display_text += text_char
		$Voice.play()
		$Label.set_text(display_text)
		yield(get_tree().create_timer(.05), "timeout")
		if current_id != id:
			return
	if use_input:
		$Label.set_text($Label.text+"    ")
		arrow.get_node("AnimationPlayer").play("Arrow")
		arrow.visible = true
		while not Input.is_action_pressed("ui_accept"):
			yield(get_tree().create_timer(.1), "timeout")
			if current_id != id:
				return
		arrow.visible = false
		shrink_text(4)
	else:
		yield(get_tree().create_timer(.5), "timeout")
		if current_id != id:
			return
	$Label.set_text("")
	"""
	while len($Label.text) > 0:
		shrink_text(1)
		yield(get_tree().create_timer(.01), "timeout")
		if current_id != id:
			return
	"""
	self.visible = false
	arrow.get_node("AnimationPlayer").stop()
	
func shrink_text(count):
	$Label.text = $Label.text.substr(0,len($Label.text)-count)
	
func _process(delta):
	update_dimensions()
			
func update_dimensions():
	if $Label.get_rect().size != $Label.get_combined_minimum_size() or $Label.get_rect().position != Vector2(-$Label.get_rect().size.x/2, -$Label.get_rect().size.y):
		$Label.set_size($Label.get_combined_minimum_size())
		$Label.set_position(Vector2(-$Label.get_rect().size.x/2, -$Label.get_rect().size.y))
		yield(get_tree(), "idle_frame")
