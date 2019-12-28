tool extends Control

var arrow
func _ready():
	$Label.connect("resized", self, "update_dimensions")
	arrow = $Label/MarginContainer/Arrow
	silence()
	
var current_id = 0

func silence():
	current_id += 1
	is_speaking = false
	$Label.set_text("")
	yield(get_tree(), "idle_frame")
	self.visible = false
	arrow.visible = false
	
const line_limt = 12
	
var is_speaking = false
			
func speak(text, use_input = true):
	is_speaking = true
	text = GameManager.auto_indent(text)
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
		arrow.visible = true
		arrow.visible = false
		shrink_text(4)
	$Label.set_text("")

	self.visible = false
	is_speaking = false
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
