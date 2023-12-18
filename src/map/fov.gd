extends TileMap


var tiles = [Vector2i(0, 0), Vector2i(1, 0)]

func setup(width, height):
	for x in range(width):
		for y in range(height):
			set_cell(0, Vector2i(x, y), 0, tiles[0])

func in_fov(pos):
	if get_cell_atlas_coords(0, pos):
		return false
		
	return true

func update_visibility(width, height, pos, sight_range):
	for x in range(width):
		for y in range(height):
			if get_cell_atlas_coords(0, Vector2i(x, y)) == Vector2i(-1, -1):
				set_cell(0, Vector2i(x, y), 0, tiles[1])
	
	for x in range(pos.x - sight_range + 1, pos.x + sight_range):
		for y in range(pos.y - sight_range + 1, pos.y + sight_range):
			var line = bres_line(pos, Vector2(x, y))
			for point in line:
				set_cell(0, point, 0, Vector2i(-1, -1))
				var tile = get_parent().get_cell_atlas_coords(0, point)
				if tile in get_parent().BLOCKSITE_TILES:
					break
	
	for mob in get_tree().get_nodes_in_group('mob'):
		if get_cell_atlas_coords(0, mob.entity_position.coords) == Vector2i(-1, -1):
			mob.visible = true
		else:
			mob.visible = false
			
	for item in get_tree().get_nodes_in_group('item'):
		if get_cell_atlas_coords(0,  item.entity_position.coords) == Vector2i(-1, -1):
			item.visible = true
		else:
			item.visible = false
			
func bres_line(start, target):
	var dx = target.x - start.x
	var dy = target.y - start.y
	
	var steep = abs(dy) > abs(dx)
	
	if steep:
		var temp = start.x
		start.x = start.y
		start.y = temp
		temp = target.x
		target.x = target.y
		target.y = temp
	
	var swapped = false
	if start.x > target.x:
		var temp = start.x
		start.x = target.x
		target.x = temp
		temp = start.y
		start.y = target.y
		target.y = temp
		swapped = true
	
	dx = target.x - start.x
	dy = target.y - start.y
	
	var err = int(dx / 2.0)
	var ystep = 1 if start.y < target.y else -1
	
	var y = start.y
	var points = []
	for x in range(start.x, target.x + 1):
		var coord = Vector2(y, x) if steep else Vector2(x, y)
		points.append(coord)
		err -= abs(dy)
		if err < 0:
			y += ystep
			err += dx
	if swapped:
		points.reverse()
		
	return points
