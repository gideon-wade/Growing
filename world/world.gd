class_name World extends Node2D
@export var noise_texture : NoiseTexture2D
var noise : Noise
var noises : Array[float] = []
var terrain_id : int = 1
var fog_id : int = 1
@onready var tile_map: TileMapLayer = $TileMap
@onready var terrain: TileMapLayer = $Terrian
@onready var fog: TileMapLayer = $Fog
@onready var ui: Control = $UI

var tile_size : int = 128
#Water
#var water_dark_atlas : Vector2i= Vector2i(2,2)
var water_semi_dark_atlas : Vector2i = Vector2i(1,2)
var water_semibright_atlas : Vector2i = Vector2i(0,2)
#var water_bright_atlas : Vector2i = Vector2i(0,2)
#dirt/sand
var dirt_dark_atlas : Vector2i = Vector2i(2,1)
var dirt_semi_dark_atlas : Vector2i = Vector2i(0,0)
var dirt_semibright_atlas : Vector2i = Vector2i(0,1)
#var dirt_bright_atlas : Vector2i = Vector2i(3,1)
#grass
var grass_dark_atlas : Vector2i = Vector2i(2,0)
var grass_semibright_atlas : Vector2i = Vector2i(1,0)
var grass_bright_atlas : Vector2i = Vector2i(1,1)
const MOUNTAIN := Vector2i(0,4)
const HELL_HILL := Vector2i(2,4)
const FOG := Vector2i(3,3)
var tiles = {}
var mobs_on_tiles = {}
const PEASANT = preload("res://art/units/peasant.png")
var mob_scene = preload("res://mobs/enemy/mob.tscn")
var player_pos = null
var next_player_pos = null

var last_mouse_pos = null
var moving = false
var stop_moving = false
var last_move_time = 0
var info_shown : bool = false


var entourage_pos = []
var entourage: Array[Mob] = []

func _ready() -> void:
	noise = noise_texture.noise
	GameManager.world_rdy(self)
	print(ui)
	print(ui.sidebar)
	print(ui.sidebar.world)
	ui.sidebar.world = self
	print(ui.sidebar.world)

func init_camera() -> void:
	$Camera.limit_left = -50
	$Camera.limit_top = -50
	$Camera.limit_right = noise_texture.width * 128.5
	$Camera.limit_bottom = noise_texture.height * 96.5

func generate():
	var rng = RandomNumberGenerator.new()
	noise.seed = rng.randi()
	place_tiles()
	place_fog()
	place_mobs()
	play_idle_tween_mobs()
	instantiate_entourage()

func place_tiles() -> void:
	for x in range(noise_texture.width):
		for y in range(noise_texture.height):
			noises.append(noise.get_noise_2d(x,y))
			var noise_val = float(noise.get_noise_2d(x,y))
			if noise_val < -0.43:
				tile_map.set_cell(Vector2(x,y), terrain_id, water_semi_dark_atlas)
			#elif noise_val < -0.34:
			#	tile_map.set_cell(Vector2(x,y), terrain_id, water_semi_dark_atlas)
			#elif noise_val < -0.21:
				#tile_map.set_cell(Vector2(x,y), terrain_id, water_semibright_atlas)
			#elif noise_val < -0.14:
				#tile_map.set_cell(Vector2(x,y), terrain_id, water_bright_atlas)
			#elif noise_val < -0.06:
				#tile_map.set_cell(Vector2(x,y), terrain_id, dirt_bright_atlas)
			elif noise_val < 0.02:
				tile_map.set_cell(Vector2(x,y), terrain_id, dirt_semibright_atlas)
			elif noise_val < 0.11:
				tile_map.set_cell(Vector2(x,y), terrain_id, dirt_semi_dark_atlas)
			#elif noise_val < 0.16:
				#tile_map.set_cell(Vector2(x,y), terrain_id, dirt_dark_atlas)
			elif noise_val < 0.22:
				tile_map.set_cell(Vector2(x,y), terrain_id, grass_bright_atlas)
			elif noise_val < 0.37:
				tile_map.set_cell(Vector2(x,y), terrain_id, grass_semibright_atlas)
				#if randi() % 3 == 0:
					#terrain.set_cell(Vector2(x,y), terrain_id, HELL_HILL)
			else:
				tile_map.set_cell(Vector2(x,y), terrain_id, grass_dark_atlas)
				#if randi() % 2 == 0:
					#terrain.set_cell(Vector2(x,y),terrain_id, MOUNTAIN)
			var clicked_cell = Vector2i(x,y)
			var tile = tile_map.get_cell_tile_data(clicked_cell)
			if tile:
				tiles[clicked_cell] = tile
	GameManager.tiles = tiles
	if player_pos == null:
		spawn_player(Vector2i(noise_texture.width / 2, noise_texture.height / 2))

func place_fog() -> void:
	for x in range(noise_texture.width):
		for y in range(noise_texture.height):
			$Fog.set_cell(Vector2(x,y), fog_id, FOG)
	update_fog(player_pos)
	
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
		$Mobs.add_child(mob)
		mob.sprite.texture = GameManager.MobToSprite[mob_name]
		var sprite_scale = Vector2(0.2, 0.2)
		mob.sprite.scale = sprite_scale
		mob.tween_controller.original_sprite_scale = sprite_scale
		mob.position = tile_to_global_pos(tile) + Vector2i(0, 10)
		mob.fog = $Fog
		mob.pos = tile
		mob.visible = false
		
func spawn_player(tile) -> void:
	while not tiles[tile].get_custom_data("Walkable"):
		tile.x -= 1
	player_pos = tile
	
	var player = mob_scene.instantiate()
	mobs_on_tiles[tile] = player
	player.mob_name = "player"
	self.add_child(player)
	player.is_player = true
	player.sprite.texture = GameManager.MobToSprite["Player"]
	player.sprite.z_index = 10
	var sprite_scale = Vector2(0.3, 0.3)
	player.sprite.scale = sprite_scale
	player.tween_controller.original_sprite_scale = sprite_scale
	player.position = tile_to_global_pos(tile)
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
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not info_shown:
			var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
			if (last_mouse_pos - pos).length() < 10 and moving:
				if Time.get_ticks_msec() - last_move_time > 250:
					stop_moving = true
			elif (last_mouse_pos - pos).length() < 10 and not moving:
				if fog.get_cell_tile_data(clicked_cell) != null:
					return
				animate_path(clicked_cell)
				last_move_time = Time.get_ticks_msec()
				
		last_mouse_pos = pos

func animate_path(clicked_cell) -> void:
	var player: Mob = mobs_on_tiles[player_pos]
	var path := find_path(player_pos, clicked_cell)
	if len(path) > 0:# and not moving:
		var flag = mob_scene.instantiate()
		flag.mob_name = "Flag"
		self.add_child(flag)
		flag.sprite.texture = GameManager.MobToSprite["Flag"]
		var sprite_scale = Vector2(0.2, 0.2)
		flag.sprite.scale = sprite_scale
		flag.tween_controller.original_sprite_scale = sprite_scale
		flag.position = tile_to_global_pos(clicked_cell)
		flag.tween_controller.idle()
		flag.z_index = 10
		moving = true

		player.audio_controller.stream = preload("res://sounds/horse_run_sfx.mp3")
		player.audio_controller.pitch_scale = 1 + (1 - 2 * randf()) * 0.05
		player.audio_controller.play()
		player.tween_controller.walk()
		
		for path_pos in path.slice(1, len(path)-1):
			var dot = mob_scene.instantiate()
			mobs_on_tiles[path_pos] = dot
			dot.mob_name = "dot"
			self.add_child(dot)
			dot.sprite.texture = GameManager.MobToSprite["PathDot"]
			dot.sprite.scale = Vector2(0.1, 0.1)
			dot.z_index = -1
			dot.tween_controller.original_sprite_scale = Vector2(0.1, 0.1)
			dot.position = tile_to_global_pos(path_pos) + Vector2i(0, 30)
		
		for i in range(len(path)):
			var path_pos = path[i]
			mobs_on_tiles[player_pos] = null
			update_entourage(player_pos)
			#if path_pos.x < player_pos.x:
			#	player.sprite.flip_h = true
			#else:
			#	player.sprite.flip_h = false
			player_pos = path_pos
			next_player_pos = path[min(i+1, len(path)-1)]
			var new_pos = tile_to_global_pos(player_pos)
			var move_tween = create_tween()
			move_tween.set_trans(Tween.TRANS_QUAD)
			move_tween.tween_property(player, "position", Vector2(new_pos), 0.5)
			await move_tween.finished
			if mobs_on_tiles.get(player_pos, null) != null and mobs_on_tiles[player_pos].mob_name == "dot":
				mobs_on_tiles[player_pos].queue_free()
			elif mobs_on_tiles.get(player_pos, null) != null:
				GameManager.start_battle(mobs_on_tiles[player_pos], get_biome(player_pos))
				mobs_on_tiles[player_pos].queue_free()
			mobs_on_tiles[player_pos] = player
			update_fog(path_pos)
			if stop_moving:
				stop_moving = false
				for j in range(i, len(path)-1):
					path_pos = path[j]
					if mobs_on_tiles.get(path_pos, null) != null and mobs_on_tiles[path_pos].mob_name == "dot":
						mobs_on_tiles[path_pos].queue_free()
						mobs_on_tiles[path_pos] = null
				break
		player.tween_controller.idle()
		moving = false
		player.audio_controller.stop()
		flag.queue_free()

func update_fog(path_pos) -> void:
	var fogs_in_vision = get_neighbour_fogs(path_pos)
	for fog in fogs_in_vision:
		$Fog.set_cell(fog, -1) # delete fog

func bfs(cur_pos: Vector2i, dist) -> Array:
	var odd = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), 
				Vector2i(-1, 0), Vector2i(1, 1), Vector2i(1, -1)]
	var even = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), 
				Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(-1, 1)]
	var queue = [cur_pos]
	var visited = {cur_pos: true}
	var distance = {cur_pos: 0}
	while not queue.is_empty():
		var pos = queue.pop_front()
		if distance[pos] >= dist:
			continue
		for neighbor in odd if pos.y%2 == 1 else even:
			var new = pos + neighbor
			if not visited.get(new, false):
				visited[new] = true
				queue.append(new)
				distance[new] = distance[pos] + 1
	
	return visited.keys()
const PLAINS := "plains"
const HILLS = "hills"
const MOUNTAINS = "mountains"

func get_neighbour_fogs(cur_pos: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var all_neighbours = bfs(cur_pos, GameManager.player_view_distance)
	for neighbor in all_neighbours:
		if fog.get_cell_tile_data(neighbor) != null:
			out.append(neighbor)
	return out

func get_biome(pos : Vector2i) -> String:
	var tile = tiles[pos]
	if tile.get_custom_data(PLAINS):
		return PLAINS
	elif tile.get_custom_data(HILLS):
		return HILLS
	elif tile.get_custom_data(MOUNTAINS):
		return MOUNTAINS
	push_error("could not find tile data for battle in pos: ", pos)
	return PLAINS 

func tile_to_global_pos(tile: Vector2i) -> Vector2i:
	return tile * Vector2i(tile_size, 96) + Vector2i(tile_size / 2, tile_size / 3) + \
					Vector2i(64 if (tile.y%2==1) else 0, -10)

func instantiate_entourage():
	for mob in entourage:
		mob.queue_free()
	entourage = []
	for unit in GameManager.units:
		var mob_name = GameManager.UnitNames[unit]
		var image = GameManager.MobToSprite[mob_name]
		for amount in ceil(log(GameManager.units[unit]+1)):
			var mob = mob_scene.instantiate()
			mob.mob_name = mob_name
			add_child(mob)
			mob.sprite.texture = image
			var sprite_scale = Vector2(0.2, 0.2)
			mob.sprite.scale = sprite_scale
			mob.tween_controller.original_sprite_scale = sprite_scale
			mob.tween_controller.idle()
			entourage.append(mob)
	if len(entourage_pos) == 0:
		entourage_pos = [player_pos]
	draw_entourage(true)

func update_entourage(pos):
	if len(entourage_pos) > 0 and (entourage_pos.front() == pos or pos == next_player_pos):
		return
	entourage_pos.push_front(pos)
	var entourage_amount = GameManager.units.values().reduce(func (acc, num): return acc + ceil(log(num+1)), 0)
	#var entourage_amount = GameManager.units.values().reduce(func (acc, num): return acc + num, 0)
	if len(entourage_pos) > entourage_amount:
		entourage_pos.pop_back()
	if len(entourage) != entourage_amount:
		instantiate_entourage()
	draw_entourage()

func draw_entourage(instant = false):
	if len(entourage_pos) == 0:
		return
	for i in range(len(entourage)):
		var pos_i = min(i, len(entourage_pos)-1)
		var e_pos = entourage_pos[pos_i]
		var new_pos = tile_to_global_pos(e_pos)
		var move_tween = create_tween()
		move_tween.set_trans(Tween.TRANS_QUAD)
		move_tween.tween_property(entourage[i], "position", Vector2(new_pos), 0.5 * int(not instant))
	
