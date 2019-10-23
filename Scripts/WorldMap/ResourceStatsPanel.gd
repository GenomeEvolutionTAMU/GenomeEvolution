extends Panel

var root
onready var tween_node = $Tween
var hidden = true
var player
var begin_tile_resources = false
var res_tree = [[],[],[],[]]

func _ready():
	root = $Tree.create_item()
	root.set_text(0, "Tile Resources")

func _on_World_Map_Control_tiles_done(tile):
	for i in range(0, 4):
		res_tree[i].append($Tree.create_item(root))
		res_tree[i][0].set_text(0, "Resource " + String(i + 1))
		for j in range(1, 11):
			res_tree[i].append($Tree.create_item(res_tree[i][0]))
			res_tree[i][j].set_text(0, "Sub-Resource " + String(i) + "-" + String(j) + ": " + String(tile.resource_2d_array[i][j - 1]))
	begin_tile_resources = true
	
func _process(delta):
	pass
#	for i in range(0, 4):
#		for j in range(1, 11):
#			res_tree[i][j].set_text(0, "Sub-Resource " + String(i) + "-" + String(j) + ": " + String(player.curr_tile.resource_2d_array[i][j - 1]))

func _on_Stats_pressed():
	if hidden:
		tween_node.interpolate_property(self, "rect_position", get_position(), Vector2(0, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween_node.start()
		hidden = false
	else:
		tween_node.interpolate_property(self, "rect_position", get_position(), Vector2(-250, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween_node.start()
		hidden = true
