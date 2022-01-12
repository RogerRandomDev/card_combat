extends TileMap




export(int) var map_w = 80
export(int) var map_h = 50
export(int) var min_room_size = 8
export(float, 0.2, 0.5) var min_room_factor = 0.4

enum Tiles { GROUND, TREE, WATER, ROOF }

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []
var stair_pos = Vector2.ZERO
var have_done_stairs = false
func ready():
	
	
	have_done_stairs = false
	randomize()
	while rooms.size() == 0:generate()
	var used = get_used_cells_by_id(0)
	for cell in used:
		set_cell(cell.x+1,cell.y+1,0)
		set_cell(cell.x,cell.y+1,0)
		set_cell(cell.x-1,cell.y+1,0)
		set_cell(cell.x-1,cell.y,0)
		set_cell(cell.x+1,cell.y,0)
		set_cell(cell.x+1,cell.y-1,0)
		set_cell(cell.x,cell.y-1,0)
		set_cell(cell.x-1,cell.y-1,0)
	update_bitmask_region(Vector2(-1,-1),Vector2(map_w,map_h)+Vector2(1,1))
	stair_pos = rooms[abs(round(rand_range(0.0,rooms.size()-1)))]["center"]
	set_cellv(stair_pos,1)
	var out_steps = Area2D.new()
	var out_col = CollisionShape2D.new()
	out_col.shape = RectangleShape2D.new()
	out_col.shape.extents = Vector2(4,4)
	out_steps.add_child(out_col)
	out_steps.position = stair_pos*8+Vector2(4,4)
	add_child(out_steps)
	out_steps.connect("body_entered",get_parent().get_parent(),"stairs_entered")

func reload_autotiles():update_bitmask_region(Vector2(-1,-1),Vector2(map_w,map_h)+Vector2(1,1))

func generate():
	clear()
	fill_roof()
	start_tree()
	create_leaf(0)
	create_rooms()
	join_rooms()
	clear_deadends()

func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(x, y, -1)

func start_tree():
	rooms = []
	tree = {}
	leaves = []
	leaf_id = 0

	tree[leaf_id] = { "x": 1, "y": 1, "w": map_w-2, "h": map_h-2 }
	leaf_id += 1


func create_leaf(parent_id):
	var x = tree[parent_id].x
	var y = tree[parent_id].y
	var w = tree[parent_id].w
	var h = tree[parent_id].h

	# used to connect the leaves later
	tree[parent_id].center = { x = floor(x + w/2), y = floor(y + h/2) }

	# whether the tree has space for a split
	var can_split = false

	# randomly split horizontal or vertical
	# if not enough width, split horizontal
	# if not enough height, split vertical
	var split_type = Util.choose(["h", "v"])
	if   (min_room_factor * w < min_room_size):  split_type = "h"
	elif (min_room_factor * h < min_room_size):  split_type = "v"

	var leaf1 = {}
	var leaf2 = {}

	# try and split the current leaf,
	# if the room will fit
	if (split_type == "v"):
		var room_size = min_room_factor * w
		if (room_size >= min_room_size):
			var w1 = Util.randi_range(room_size, (w - room_size))
			var w2 = w - w1
			leaf1 = { x = x, y = y, w = w1, h = h, split = 'v' }
			leaf2 = { x = x+w1, y = y, w = w2, h = h, split = 'v' }
			can_split = true
	else:
		var room_size = min_room_factor * h
		if (room_size >= min_room_size):
			var h1 = Util.randi_range(room_size, (h - room_size))
			var h2 = h - h1
			leaf1 = { x = x, y = y, w = w, h = h1, split = 'h' }
			leaf2 = { x = x, y = y+h1, w = w, h = h2, split = 'h' }
			can_split = true

	# rooms fit, lets split
	if (can_split):
		leaf1.parent_id    = parent_id
		tree[leaf_id]      = leaf1
		tree[parent_id].l  = leaf_id
		leaf_id += 1

		leaf2.parent_id    = parent_id
		tree[leaf_id]      = leaf2
		tree[parent_id].r  = leaf_id
		leaf_id += 1

		# append these leaves as branches from the parent
		leaves.append([tree[parent_id].l, tree[parent_id].r])

		# try and create more leaves
		create_leaf(tree[parent_id].l)
		create_leaf(tree[parent_id].r)


func create_rooms():
# warning-ignore:shadowed_variable
	for leaf_id in tree:
		var leaf = tree[leaf_id]
		if leaf.has("l"): continue # if node has children, don't build rooms

		if Util.chance(75):
			var room = {}
			room.id = leaf_id;
			room.w  = Util.randi_range(min_room_size, leaf.w) - 1
			room.h  = Util.randi_range(min_room_size, leaf.h) - 1
			room.x  = leaf.x + floor((leaf.w-room.w)/2) + 1
			room.y  = leaf.y + floor((leaf.h-room.h)/2) + 1
			room.split = leaf.split

			room.center = Vector2()
			room.center.x = floor(room.x + room.w/2)
			room.center.y = floor(room.y + room.h/2)
			rooms.append(room);

	# draw the rooms on the tilemap
	for i in range(rooms.size()):
		var r = rooms[i]
		for x in range(r.x, r.x + r.w):
			for y in range(r.y, r.y + r.h):
				set_cell(x, y, 0)


func join_rooms():
	for sister in leaves:
		var a = sister[0]
		var b = sister[1]
		connect_leaves(tree[a], tree[b])

func connect_leaves(leaf1, leaf2):
	var x = min(leaf1.center.x, leaf2.center.x)
	var y = min(leaf1.center.y, leaf2.center.y)
	var w = 1
	var h = 1

	# Vertical corridor
	if (leaf1.split == 'h'):
		x -= floor(w/2)+1
		h = abs(leaf1.center.y - leaf2.center.y)
	else:
		# Horizontal corridor
		y -= floor(h/2)+1
		w = abs(leaf1.center.x - leaf2.center.x)

	# Ensure within map
	x = 0 if (x < 0) else x
	y = 0 if (y < 0) else y

	for i in range(x, x+w):
		for j in range(y, y+h):
			if(get_cell(i, j) == -1): set_cell(i, j, 0)

func clear_deadends():
	var done = false

	while !done:
		done = true

		for cell in get_used_cells():
			if get_cellv(cell) != 0: continue

			var roof_count = check_nearby(cell.x, cell.y)
			if roof_count == 3:
				set_cellv(cell, -1)
				done = false

# check in 4 dirs to see how many tiles are roofs
func check_nearby(x, y):
	var count = 0
	if get_cell(x, y-1)   == -1:  count += 1
	if get_cell(x, y+1)   == -1:  count += 1
	if get_cell(x-1, y)   == -1:  count += 1
	if get_cell(x+1, y)   == -1:  count += 1
	return count
