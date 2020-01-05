extends Switch

export(NodePath) onready var source_a = get_node(source_a) if source_a else null
export(NodePath) onready var source_b = get_node(source_b) if source_b else null
export(NodePath) onready var source_c = get_node(source_c) if source_c else null

var sources = []

# Called when the node enters the scene tree for the first time.
func _ready():
	sources = [source_a, source_b, source_c]
	for source in sources:
		if source == null:
			sources.erase(source)
		else:
			source.connect("set_on", self, "set_source_on")
	pass # Replace with function body.

func set_source_on(source, value):
	if value:
		for source in sources:
			if !source.is_on:
				value = false
				break
	if value != is_on:
		set_on(value)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
