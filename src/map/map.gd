extends TileMap

@export var width: int
@export var height: int
@onready var spawner = $spawner
@onready var full_prefabs = [preload("res://src/map/prefabs/full/loot_n_mobs.tscn"), preload("res://src/map/prefabs/full/tunnels_n_rooms.tscn")]

var TileType = {
	FLOOR = Vector2i(0, 28),
	MOUNTAIN = Vector2i(2, 19),
	STAIRS = Vector2i(5, 30),
	VASE = Vector2i(4, 29),
	GOLDVASE = Vector2i(5, 29),
	CHEST = Vector2i(9, 7),
	DEATH = Vector2i(9, 13),
	PREFAB_MARKER = Vector2i(0, 19)
}

var WALKABLE_TILES = [TileType.FLOOR]
var BLOCKABLE_TILES = [TileType.MOUNTAIN, TileType.VASE, TileType.GOLDVASE, TileType.CHEST]
var BLOCKSITE_TILES = [TileType.MOUNTAIN]

@onready var fov = $fov
var astar = AStarGrid2D.new()
var current_floor = 1

func _ready():
	add_to_group("map")
	restart()

func clear_entities(delete_player = false):
	if delete_player:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.queue_free()
			
	for mob in get_tree().get_nodes_in_group("mob"):
		mob.queue_free()
	for item in get_tree().get_nodes_in_group("item"):
		if !item.picked_up:
			item.queue_free()
		
func restart():
	modulate.a = 0
	clear_entities(true)
	await get_tree().create_timer(1).timeout
	generate_cave()
	init_astar()
	fov.setup(width, height)
	var player = get_tree().get_first_node_in_group("player")
	fov.update_visibility(width, height, player.entity_position.coords, player.status.stats.sight_range)
	
	var turn_queue = get_tree().get_first_node_in_group("queue")
	turn_queue.init(self)
	
	modulate.a = 1
	
func next_floor():
	modulate.a = 0
	clear_entities()
	await get_tree().create_timer(1).timeout
	if current_floor < 4:
		generate_cave()
	else:
		load_prefab(full_prefabs[randi_range(0, len(full_prefabs)-1)], Vector2.ZERO)
		
	init_astar()
	fov.setup(width, height)
	var player = get_tree().get_first_node_in_group("player")
	fov.update_visibility(width, height, player.entity_position.coords, player.status.stats.sight_range)
	
	var turn_queue = get_tree().get_first_node_in_group("queue")
	turn_queue.init(self)
	
	current_floor += 1
	modulate.a = 1

func walkable(pos):
	var tile = get_cell_atlas_coords(0, pos)
	
	if tile in BLOCKABLE_TILES:
		return tile
	else:
		for player in get_tree().get_nodes_in_group("player"):
			if player.entity_position.coords == Vector2(pos):
				return player
				
		for mob in get_tree().get_nodes_in_group("mob"):
			if mob.entity_position.coords == Vector2(pos):
				return mob
		
	return null

func check_tile_interaction(pos, tile):
	match tile:
		TileType.VASE, TileType.GOLDVASE:
			set_cell(0, pos, 1, TileType.FLOOR)
			spawner.spawn_random_item(self, pos)
			var audio = get_tree().get_first_node_in_group("audio")
			audio.play_destroy_vase()
			return true
		TileType.CHEST:
			set_cell(0, pos, 1, TileType.FLOOR)
			spawner.spawn_chest_item(self, pos)
			var audio = get_tree().get_first_node_in_group("audio")
			audio.play_destroy_vase()
			return true
			
	return false

# Map gen
@export var CHANCE_FLOOR: int
@export var CA_VARIENCE: int
@export var CA_ITERATIONS: int
@export var CA_MOB_SPAWN_AMOUNT: int
@export var CA_OBJ_SPAWN_AMOUNT: int
@export var CA_MIN_OPEN_PERCENT: float

func load_prefab(prefab, pos):
	var loaded = prefab.instantiate()
	var player_spawn_loc = null
	var mob_spawn_locs = []
	for tile_pos in loaded.get_used_cells(0):
		var tile = loaded.get_cell_atlas_coords(0, tile_pos)
		if tile != TileType.PREFAB_MARKER:
			set_cell(0, tile_pos, 1, tile)
		else:
			set_cell(0, tile_pos, 1, TileType.FLOOR)
			var alt = loaded.get_cell_alternative_tile(0, tile_pos)
			match alt:
				1: player_spawn_loc = tile_pos
				2: mob_spawn_locs.push_back(tile_pos)
	
	for spawn_pos in mob_spawn_locs:
		spawner.spawn_mob(self, spawn_pos, current_floor)
	
	# If player spawn location is present it means the prefab is a full map
	# Otherwise its a partial prefab which don't have set spawn points for the player
	if player_spawn_loc:
		var player = get_tree().get_first_node_in_group("player")
		if !player:
			spawner.spawn_player(self, player_spawn_loc)
		else:
			player.entity_position.coords = Vector2(player_spawn_loc)
			player.position = player_spawn_loc * 8
		
	# Destroy loaded prefab node
	loaded.queue_free()
	
func in_bounds(pos):
	if pos.x > 1 && pos.x < width-1 && pos.y > 1 && pos.y < height-1:
		return true
	
	return false
	
func fill(tile):
	for x in range(width):
		for y in range(height):
			set_cell(0, Vector2(x, y), 1, tile)

func random_tiles():
	for x in range(1, width-1):
		for y in range(1, height-1):
			if randi_range(0, 100) <= CHANCE_FLOOR+randi_range(-CA_VARIENCE, 0):
				set_cell(0, Vector2(x, y), 1, TileType.FLOOR)
			else:
				set_cell(0, Vector2(x, y), 1, TileType.MOUNTAIN)

func ca_iterate():
	for x in range(1, width-1):
		for y in range(1, height-1):
			var tile = get_cell_atlas_coords(0, Vector2(x, y))
			var walls = 0
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					if dx != 0 or dy != 0:
						var check_tile = get_cell_atlas_coords(0, Vector2(x+dx, y+dy))
						if check_tile == TileType.MOUNTAIN:
							walls += 1
			
			if tile == TileType.FLOOR:
				if walls > 4:
					set_cell(0, Vector2(x, y), 1, TileType.MOUNTAIN)
			elif tile == TileType.MOUNTAIN:
				if walls < 3:
					set_cell(0, Vector2(x, y), 1, TileType.FLOOR)

func blank():
	# Create one tile wide horizontal blanks
	for x in range(2, width-2):
		for y in range(2, 3):
			set_cell(0, Vector2(x, y), 1, TileType.FLOOR)
		for y in range(15, 16):
			set_cell(0, Vector2(x, y), 1, TileType.FLOOR)
		for y in range(26, 27):
			set_cell(0, Vector2(x, y), 1, TileType.FLOOR)
	
	# Create one tile wide vertical blank
	for y in range(2, height-2):
		for x in range(2, 3):
			set_cell(0, Vector2(x, y), 1, TileType.FLOOR)
		for x in range(25, 26):
			set_cell(0, Vector2(x, y), 1, TileType.FLOOR)
		for x in range(46, 47):
			set_cell(0, Vector2(x, y), 1, TileType.FLOOR)

func check_connection(start):
	init_astar()
	var spawn_locations = get_used_cells_by_id(0, 1, TileType.FLOOR)
	var stair_dist = 0
	var stair_loc = Vector2.ZERO
	for tile in spawn_locations:
		var path = find_path(start, tile)
		if !path:
			set_cell(0, tile, 1, TileType.MOUNTAIN)
		else:
			if len(path) > stair_dist:
				stair_dist = len(path)
				stair_loc = tile
	
	# Set stairs
	set_cell(0, stair_loc, 1, TileType.STAIRS)
	
func generate_cave():
	# Keep regening map until enough tiles are open(thus dungeon isnt too small due to culling)
	fill(TileType.MOUNTAIN)
	var open_locations =  get_used_cells_by_id(0, 1, TileType.FLOOR)
	var player_spawn_loc = null
	while len(open_locations) < (width*height) * CA_MIN_OPEN_PERCENT:
		fill(TileType.MOUNTAIN)
		random_tiles()
		blank()
		for i in range(CA_ITERATIONS):
			ca_iterate()
		
		open_locations =  get_used_cells_by_id(0, 1, TileType.FLOOR)
		var random_index = randi_range(0, len(open_locations)-1)
		player_spawn_loc = open_locations[random_index]
		check_connection(open_locations[random_index])
		open_locations =  get_used_cells_by_id(0, 1, TileType.FLOOR)
		
	# Spawn player, move them instead if already alive
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		spawner.spawn_player(self, player_spawn_loc)
	else:
		player.entity_position.coords = Vector2(player_spawn_loc)
		player.position = player_spawn_loc * 8

	# Spawn rest of map
	spawn_mobs_area(open_locations)
	spawn_obj_area()
	
func spawn_mobs_area(spawn_locations):
	if len(spawn_locations)-1 > 0:
		for i in range(CA_MOB_SPAWN_AMOUNT):
			var fail = 10
			while fail > 0:
				var random_index = randi_range(0, len(spawn_locations)-1)
				var spawn_loc = spawn_locations[random_index]
				var blocker = walkable(spawn_loc)
				if !blocker:
					spawner.spawn_mob(self, spawn_locations[random_index], current_floor)
					spawn_locations.remove_at(random_index)
					break
				
				fail -= 1
			
func spawn_obj_area():
	var spawn_locations = get_free_areas_near_wall()
	if len(spawn_locations) > 0:
		for i in range(CA_OBJ_SPAWN_AMOUNT):
			var random_index = randi_range(0, len(spawn_locations)-1)
			if randi_range(1, 10) > 1:
				set_cell(0, spawn_locations[random_index], 1, TileType.VASE if randi_range(0, 10) < 8 else TileType.GOLDVASE)
			else:
				set_cell(0, spawn_locations[random_index], 1, TileType.CHEST)

func get_free_areas_near_wall():
	var spawn_locations = get_used_cells_by_id(0, 1, TileType.FLOOR)
	var near_wall_locs = []
	for spawn in spawn_locations:
		if near_wall(spawn):
			near_wall_locs.push_back(spawn)
			
	return near_wall_locs

func near_wall(pos):
	if get_cell_atlas_coords(0, pos+Vector2i.UP) == TileType.MOUNTAIN:
		return true
	elif get_cell_atlas_coords(0, pos+Vector2i.RIGHT) == TileType.MOUNTAIN:
		return true
	elif get_cell_atlas_coords(0, pos+Vector2i.DOWN) == TileType.MOUNTAIN:
		return true
	elif get_cell_atlas_coords(0, pos+Vector2i.LEFT) == TileType.MOUNTAIN:
		return true
	
	return false
				
# Pathfinding
func init_astar():
	astar.size = Vector2(width, height)
	astar.cell_size = Vector2i(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	calculate_astar()
	
func calculate_astar():
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var tile = get_cell_atlas_coords(0, pos)
			if tile in BLOCKABLE_TILES:
				astar.set_point_solid(pos)
			else:
				var blocked = false
				for mob in get_tree().get_nodes_in_group("mob"):
					if mob.entity_position.coords == Vector2(pos):
						astar.set_point_solid(pos)
						blocked = true
						break
				
				if !blocked:
					astar.set_point_solid(pos, false)

func find_path(start, target):
	return astar.get_point_path(start, target)
