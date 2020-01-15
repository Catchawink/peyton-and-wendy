extends Node2D

var arrow
var label
func _ready():
	label = $Container/Label
	arrow = $Container/Label/MarginContainer/Arrow
	silence()
	
var current_id = 0

func silence():
	current_id += 1
	is_speaking = false
	label.set_text("")
	yield(get_tree(), "idle_frame")
	self.visible = false
	arrow.visible = false
	
const line_limt = 12
	
var is_speaking = false
			
func speak(text, use_input = true, interrupt=false, line_limit=-1, accelerate=false):
	is_speaking = true
	text = GameManager.auto_indent(text, line_limit)
	arrow.visible = false
	text = text.to_upper()
	self.visible = true
	var display_text = ""
	var id = current_id+1
	current_id = id
	var time_scale = 1
	for text_char in text:
		display_text += text_char
		$Voice.play()
		label.set_text(display_text)
		var time = .05
		if text_char == "." or text_char == "!" or text_char == "?":
			time = .1
		time = time*time_scale
		if accelerate:
			time_scale -= .1*time
		
		yield(get_tree().create_timer(time), "timeout")
		if current_id != id:
			return
	if use_input:
		label.set_text(label.text+"    ")
		arrow.get_node("AnimationPlayer").play("Arrow")
		arrow.visible = true
		while not Input.is_action_pressed("ui_accept"):
			yield(get_tree().create_timer(.1), "timeout")
			if current_id != id:
				return
		arrow.visible = false
		shrink_text(4)
	else:
		if !interrupt:
			var readingtime = len(text) / 15.00
			yield(get_tree().create_timer(readingtime), "timeout")
			if current_id != id:
				return
		arrow.visible = true
		arrow.visible = false
		shrink_text(4)
	label.set_text("")

	self.visible = false
	is_speaking = false
	arrow.get_node("AnimationPlayer").stop()
	
func shrink_text(count):
	label.text = label.text.substr(0,len(label.text)-count)
