### Level.gd

extends Node2D

# Node references
@onready var tilemap = $TileMap
@onready var enemy_scene = preload("res://Scenes/enemy.tscn")

# Randomizer & Dimension values ( make sure width & height is uneven)
const initial_width = 30 
const initial_height = 30 
var map_width = initial_width
var map_height = initial_height 
var map_offset = 0 #Shifts map four rows down for UI
var rng = RandomNumberGenerator.new()
var num_enemies = 10

# Tilemap constants
const BACKGROUND_TILE_ID = 0
const BREAKABLE_TILE_ID = 1
const UNREAKABLE_TILE_ID = 2
const BACKGROUND_TILE_LAYER = 0
const BREAKABLE_TILE_LAYER = 1
const UNREAKABLE_TILE_LAYER = 2
const SPECIAL_TILE_ID = 3
const SPECIAL_TILE_LAYER = 3


func _ready():
	generate_map()
	create_player()
	place_special_tile()
	var timer = $Timer
	timer.wait_time = 1.0
	timer.autostart = true
	timer.start()
	timer.connect("timeout", Callable(self, "_on_timer_timeout" ))

func create_player():
	var player_scene = preload("res://Scenes/Player.tscn")
	var player = player_scene.instantiate()
	player.global_position = tilemap.map_to_local(Vector2(3,3))
	
func spawn_enemies():
	var spawned = 0
	while spawned < num_enemies:
		# Random position within the maze
		var x = rng.randi_range(1, map_width - 2)
		var y = rng.randi_range(1, map_height - 2) + map_offset
		
		var cell_coords = Vector2i(x, y)
		
		# Check if the cell is empty and away from the player's starting position
		if is_cell_empty(BREAKABLE_TILE_LAYER, cell_coords) and is_cell_empty(UNREAKABLE_TILE_LAYER, cell_coords) and cell_coords.distance_to(Vector2i(3, 3 + map_offset)) > 4:
			
			# Instantiate enemy and set its position
			var enemy = enemy_scene.instance()
			enemy.global_position = tilemap.map_to_world(cell_coords) + tilemap.cell_size / 2  # Center in the cell
			add_child(enemy)
			spawned += 1
	
# ---------------- Map Generation -------------------------------------
func generate_map():
	generate_unbreakables()
	generate_breakables()
	generate_background()
	
func place_special_tile():
	# Bottom right position is (map_width - 1, map_height - 1)
	var bottom_right = Vector2i(map_width - 2, map_height - 2 + map_offset)
	
	# Set the special tile on the designated layer
	tilemap.set_cell(SPECIAL_TILE_LAYER, bottom_right, SPECIAL_TILE_ID, Vector2i(0, 0), 0)


# Checks if tiles are empty or not
func is_cell_empty(layer, coords):
	var data = tilemap.get_cell_tile_data(layer, coords)
	return data == null
	
func generate_unbreakables():
	#--------------------------------- UBREAKABLES ------------------------------
	# Generate unbreakable walls at the borders on Layer 2
	for x in range(map_width):
		for y in range(map_height):
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				tilemap.set_cell(UNREAKABLE_TILE_LAYER, Vector2i(x, y + map_offset), UNREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	# Generate solid walls in a grid on Layer 2, starting from (1, 1)
	for x in range(1, map_width - 2):  # Stop before the last column
		for y in range(1, map_height - 2):  # Stop before the last row
			if x % 2 == 0 and y % 2 == 0: # Check if row and column are even
				tilemap.set_cell(UNREAKABLE_TILE_LAYER, Vector2i(x, y + map_offset), UNREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	
func generate_breakables():
	#--------------------------------- BREAKABLES ------------------------------
	# Define an array for the corners and their safe zones
	var spawn_zones = [
		# Near top-left corner
		[Vector2i(1, 1 + map_offset), Vector2i(1, 2 + map_offset), Vector2i(1, 3 + map_offset)],
		# Near top-right corner
		[Vector2i(map_width - 2, 1 + map_offset), Vector2i(map_width - 2, 2 + map_offset), Vector2i(map_width - 2, 3 + map_offset)],
		# Near bottom-left corner
		[Vector2i(1, map_height - 2 + map_offset), Vector2i(1, map_height - 3 + map_offset), Vector2i(1, map_height - 4 + map_offset)],
		# Near bottom-right corner
		[Vector2i(map_width - 2, map_height - 2 + map_offset), Vector2i(map_width - 2, map_height - 3 + map_offset), Vector2i(map_width - 2, map_height - 4 + map_offset)]
	]

	# Randomly place breakable walls on Layer 1
	rng.randomize()
	for x in range(1, map_width - 1):
		for y in range(1, map_height - 1):
			var base_breakable_chance = 0.2  # default 20% chance
			var level_chance_multiplier = 0.01  # increase by 1% per level
			var breakable_spawn_chance = base_breakable_chance + (GlobalData.current_level - 1) * level_chance_multiplier
			breakable_spawn_chance = min(breakable_spawn_chance, 0.5) #max chance of 50%
			var current_cell = Vector2i(x, y  + map_offset)
			var skip_current_cell = false
			# Skip cells where solid tiles are placed
			if x % 2 == 0 and y % 2 == 0:
				skip_current_cell = true
			# Skip cells in the spawn_zones
			for corner in spawn_zones:
				if current_cell in corner:
					skip_current_cell = true
					break
			if skip_current_cell:
				continue
			# Place breakables
			if is_cell_empty(BREAKABLE_TILE_LAYER, current_cell):
				if rng.randf() < breakable_spawn_chance: 
					tilemap.set_cell(BREAKABLE_TILE_LAYER, current_cell, BREAKABLE_TILE_ID, Vector2i(0, 0), 0)

func generate_background():
	#--------------------------------- BACKGROUND ------------------------------
	for x in range(map_width):
		for y in range(map_height):
			var cell_coords = Vector2i(x, y + map_offset)
			if is_cell_empty(BREAKABLE_TILE_LAYER, cell_coords) and is_cell_empty(UNREAKABLE_TILE_LAYER, cell_coords):
				tilemap.set_cell(BACKGROUND_TILE_LAYER, cell_coords, BACKGROUND_TILE_ID, Vector2i(0, 0), 0)


#------------------------------------ TIMER -----------------------




func _on_timer_timeout():
	GlobalData.maze_time_ -= 1
	
	if GlobalData.maze_time_ <=0:
		get_tree().change_scene_to_file("res://Scenes/classroom.tscn")
