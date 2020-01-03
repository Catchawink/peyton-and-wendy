tool extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.editor_hint:
		for cell_pos in get_used_cells():
			set_cellv(cell_pos, INVALID_CELL)
	pass # Replace with function body.

var world_offset = Vector2(8,8)
var node_positions

func update_tiles():
	node_positions = []
	for node in get_children():
		var cell_pos = world_to_map(node.position-world_offset)
		if get_cellv(cell_pos) == INVALID_CELL or node_positions.has(cell_pos):
			node.queue_free()
		else:
			node_positions.append(cell_pos)

	for cell_pos in get_used_cells():
		if node_positions.has(cell_pos):
			continue
		var name = get_tileset().tile_get_name(get_cellv(cell_pos))
		var node = load("res://scenes/items/"+name+".tscn").instance()
		add_child(node)
		node.set_owner(owner) 
		node.position = map_to_world(cell_pos)+world_offset
		var is_x_flipped = is_cell_x_flipped(cell_pos.x, cell_pos.y)
		var is_y_flipped = is_cell_y_flipped(cell_pos.x, cell_pos.y)
		if "flip_h" in node and is_x_flipped != null:
			node.flip_h = is_x_flipped
		if "flip_v" in node and is_y_flipped != null:
			node.flip_v = is_y_flipped
		if is_cell_transposed(cell_pos.x, cell_pos.y):
			node.rotation_degrees = 90
		#set_cell(cell_pos.x, cell_pos.y, -1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		update_tiles()
	pass
