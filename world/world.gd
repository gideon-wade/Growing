class_name World extends Node2D
@export var noise_texture : NoiseTexture2D
var noise : Noise
var noises : Array[float] = []
var source_id : int = 1
@onready var tile_map: TileMapLayer = $TileMap
@onready var terrain: TileMapLayer = $Terrian
var tile_size : int = 128
#Water
var water_dark_atlas : Vector2i= Vector2i(2,2)
var water_semi_dark_atlas : Vector2i = Vector2i(1,2)
var water_semibright_atlas : Vector2i = Vector2i(0,2)
#var water_bright_atlas : Vector2i = Vector2i(0,2)
#dirt/sand
var dirt_dark_atlas : Vector2i = Vector2i(2,1)
var dirt_semi_dark_atlas : Vector2i = Vector2i(1,1)
var dirt_semibright_atlas : Vector2i = Vector2i(0,1)
#var dirt_bright_atlas : Vector2i = Vector2i(3,1)
#grass
var grass_dark_atlas : Vector2i = Vector2i(2,0)
var grass_semibright_atlas : Vector2i = Vector2i(1,0)
var grass_bright_atlas : Vector2i = Vector2i(0,0)
const MOUNTAIN := Vector2i(0,4)
const HELL_HILL := Vector2(2,4)

var tiles = {}
var mobs_on_tiles = {}
const PEASANT = preload("res://art/units/peasant.png")
var mob_scene = preload("res://mobs/enemy/mob.tscn")
var player_pos = null

var last_mouse_pos = null
var moving = false

func _ready() -> void:
	noise = noise_texture.noise
	GameManager.world_rdy(self)

func generate():
	var rng = RandomNumberGenerator.new()
	noise.seed = rng.randi()
	place_tiles()
	place_mobs()
	play_idle_tween_mobs()

func place_tiles() -> void:
	for x in range(noise_texture.width):
		for y in range(noise_texture.height):
			noises.append(noise.get_noise_2d(x,y))
			var noise_val = float(noise.get_noise_2d(x,y))
			if noise_val < -0.43:
				tile_map.set_cell(Vector2(x,y), source_id, water_dark_atlas)
			elif noise_val < -0.34:
				tile_map.set_cell(Vector2(x,y), source_id, water_semi_dark_atlas)
			elif noise_val < -0.21:
				tile_map.set_cell(Vector2(x,y), source_id, water_semibright_atlas)
			#elif noise_val < -0.14:
				#tile_map.set_cell(Vector2(x,y), source_id, water_bright_atlas)
			#elif noise_val < -0.06:
				#tile_map.set_cell(Vector2(x,y), source_id, dirt_bright_atlas)
			elif noise_val < 0.02:
				tile_map.set_cell(Vector2(x,y), source_id, dirt_semibright_atlas)
			elif noise_val < 0.11:
				tile_map.set_cell(Vector2(x,y), source_id, dirt_semi_dark_atlas)
			elif noise_val < 0.16:
				tile_map.set_cell(Vector2(x,y), source_id, dirt_dark_atlas)
			elif noise_val < 0.22:
				tile_map.set_cell(Vector2(x,y), source_id, grass_bright_atlas)
			elif noise_val < 0.37:
				tile_map.set_cell(Vector2(x,y), source_id, grass_semibright_atlas)
				if randi() % 3 == 0:
					terrain.set_cell(Vector2(x,y), source_id, HELL_HILL)
			else:
				tile_map.set_cell(Vector2(x,y), source_id, grass_dark_atlas)
				if randi() % 2 == 0:
					terrain.set_cell(Vector2(x,y),source_id, MOUNTAIN)
				if player_pos == null:
					spawn_player(Vector2i(x, y))
			var clicked_cell = Vector2i(x,y)
			var tile = tile_map.get_cell_tile_data(clicked_cell)
			if tile:
				tiles[clicked_cell] = tile
		GameManager.tiles = tiles
				
func place_mobs() -> void:
	for tile in tiles:
		var valid = true
		if tiles[tile].get_custom_data("Can Spawn"):
			for i in range(5):
				for j in range(5):
					if tiles.get(tile + Vector2i(i,j), null) and mobs_on_tiles.get(tile + Vector2i(i,j), false):
						valid = false
					if tiles.get(tile - Vector2i(i,j), null) and mobs_on_tiles.get(tile - Vector2i(i,j), false):
						valid = false
					if tiles.get(tile + Vector2i(-i,j), null) and mobs_on_tiles.get(tile + Vector2i(-i,j), false):
						valid = false
					if tiles.get(tile + Vector2i(i,-j), null) and mobs_on_tiles.get(tile + Vector2i(i,-j), false):
						valid = false
			if valid:
				spawn_mob(tile)

func spawn_mob(tile) -> void:
	var mob_name = GameManager.decide_random_mob()
	if mob_name != "":
		var mob = mob_scene.instantiate()
		mobs_on_tiles[tile] = mob
		mob.mob_name = mob_name
		self.add_child(mob)
		mob.sprite.texture = GameManager.MobToSprite[mob_name]
		var sprite_scale = Vector2(0.2, 0.2)
		mob.sprite.scale = sprite_scale
		mob.tween_controller.original_sprite_scale = sprite_scale
		mob.position = tile * Vector2i(tile_size, 96) + Vector2i(tile_size / 2, tile_size / 3) + Vector2i(64 if (tile.y%2==1) else 0, 0)

func spawn_player(tile) -> void:
	player_pos = tile
	
	var player = mob_scene.instantiate()
	mobs_on_tiles[tile] = player
	player.mob_name = "player"
	self.add_child(player)
	player.sprite.texture = GameManager.MobToSprite["Player"]
	var sprite_scale = Vector2(0.3, 0.3)
	player.sprite.scale = sprite_scale
	player.tween_controller.original_sprite_scale = sprite_scale
	player.position = tile * Vector2i(tile_size, 96) + Vector2i(tile_size / 2, tile_size / 3) + \
						Vector2i(64 if (tile.y%2==1) else 0, -10)
	$Camera.global_position = player.global_position


func play_idle_tween_mobs() -> void:
	for tile in mobs_on_tiles:
		mobs_on_tiles[tile].tween_controller.idle(true)

func neighbors(cur: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var odd = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), 
				Vector2i(-1, 0), Vector2i(1, 1), Vector2i(1, -1)]
	var even = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), 
				Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(-1, 1)]
	var ways = odd if cur.y % 2 == 1 else even
	for way in ways:
		var new = cur + way
		if 0 <= new.y and new.y < noise_texture.height and 0 <= new.x and new.x < noise_texture.width:
			if tiles[new].get_custom_data("Walkable"):# and mobs_on_tiles.get(new, null) == null:
				out.append(new)
	return out
	
func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	
	var queue = [start]
	var visited = {}
	
	var gScore = {}
	gScore[start] = 0
	
	var fScore = {}
	fScore[start] = start.distance_squared_to(end)
	
	var parent = {}
	while len(queue) > 0:
		var cur = queue.reduce(func (a, b): return a if fScore[a] < fScore[b] else b)
		if cur == end:
			path = [cur]
			while cur != start:
				cur = parent[cur]
				path.append(cur)
			path.reverse()
			return path
		queue.remove_at(queue.find(cur))
		visited[cur] = true
		for pos in neighbors(cur):
			if mobs_on_tiles.get(pos, null) != null and pos != end:
				continue
			var ten_gScore = gScore[cur] + 1
			if ten_gScore < gScore.get(pos, INF):
				parent[pos] = cur
				gScore[pos] = ten_gScore
				fScore[pos] = ten_gScore + cur.distance_squared_to(pos)
				if not visited.has(pos):
					queue.append(pos)
	
	return path

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var pos = event.position
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if (last_mouse_pos - pos).length() < 10 and not moving:
				var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
				var player: Mob = mobs_on_tiles[player_pos]
				var path := find_path(player_pos, clicked_cell)
				if len(path) > 0:# and not moving:
					var flag = mob_scene.instantiate()
					#mobs_on_tiles[clicked_cell] = flag
					flag.mob_name = "Flag"
					self.add_child(flag)
					flag.sprite.texture = GameManager.MobToSprite["Flag"]
					var sprite_scale = Vector2(0.2, 0.2)
					flag.sprite.scale = sprite_scale
					flag.tween_controller.original_sprite_scale = sprite_scale
					flag.position = clicked_cell * Vector2i(tile_size, 96) + Vector2i(tile_size / 2, tile_size / 3) + \
										Vector2i(64 if (clicked_cell.y%2==1) else 0, -10)
					flag.tween_controller.idle()
					moving = true
					player.tween_controller.walk()
					mobs_on_tiles[player_pos] = null
					
					for path_pos in path.slice(1, len(path)-1):
						var dot = mob_scene.instantiate()
						mobs_on_tiles[path_pos] = dot
						dot.mob_name = "dot"
						self.add_child(dot)
						dot.sprite.texture = GameManager.MobToSprite["PathDot"]
						dot.sprite.scale = Vector2(0.1, 0.1)
						dot.z_index = -1
						dot.tween_controller.original_sprite_scale = Vector2(0.1, 0.1)
						dot.position = path_pos * Vector2i(tile_size, 96) + Vector2i(tile_size / 2, tile_size / 3) + \
											Vector2i(64 if (path_pos.y%2==1) else 0, 20)
					for path_pos in path:
						player_pos = path_pos
						var new_pos = player_pos * Vector2i(tile_size, 96) + Vector2i(tile_size / 2, tile_size / 3) + \
											Vector2i(64 if (player_pos.y%2==1) else 0, -10)
						var move_tween = create_tween()
						move_tween.set_trans(Tween.TRANS_QUAD)
						move_tween.tween_property(player, "position", Vector2(new_pos), 0.5)
						await move_tween.finished
						if mobs_on_tiles.get(player_pos, null) != null and mobs_on_tiles[player_pos].mob_name == "dot":
							mobs_on_tiles[player_pos].queue_free()
							mobs_on_tiles[player_pos] = null
						if mobs_on_tiles.get(player_pos, null) != null:
							GameManager.start_battle(mobs_on_tiles[player_pos])
							mobs_on_tiles[player_pos].queue_free()
						mobs_on_tiles[player_pos] = player
					player.tween_controller.idle()
					moving = false
					flag.queue_free()
		last_mouse_pos = pos
