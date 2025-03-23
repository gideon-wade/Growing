class_name Map extends Node2D
@onready var audio: AudioStreamPlayer2D = $Audio

signal battle_won(reward :String)
signal battle_lost
signal battle_start
enum State {
	PREGAME,
	BATTLE,
	POSTGAME
}
const IMP_SPAWN := "ImpSpawn"
const SNAKE_SPAWN := "SnakeSpawn"
const GHOST_SPAWN := "GhostSpawn"
var state = State.PREGAME
@onready var spawn_points = {GameManager.UnitType.IMP: [self.find_child(IMP_SPAWN)],
							GameManager.UnitType.SNAKE: [self.find_child(SNAKE_SPAWN)],
							GameManager.UnitType.GHOST: [self.find_child(GHOST_SPAWN)],
							}
@onready var plains := $BiomeMaps/Plains0
@onready var hills := $BiomeMaps/Hils0
@onready var mountains := $BiomeMaps/Mountain0
var biome : String = "hilly"
var mob: Mob
var camera: Camera2D
var border : Sprite2D 
var enemy_border : Sprite2D
const PLAINS = "plains"
const HILLS = "hills"
const MOUNTAINS = "mountains"

var active_tile_map : TileMapLayer

func _on_ready() -> void:
	GameManager.map = self
	spawn_tile_map()
	spawnPlayerUnits(generate_player_units())
	var enemies = GameManager.generate_enemies(mob)
	print("enemies: ",enemies)
	spawnEnemyUnits(enemies)

func _process(delta: float) -> void:
	if state == State.PREGAME:
		if GameManager.get_units(Player).any(func (unit): return unit.held or unit.in_unsafe_place()):
			camera.frozen = true
		else:
			camera.frozen = false
	if state != State.POSTGAME:
		var players = 0
		var enemies = 0
		for unit in get_children():
			if unit is Player:
				players += 1
				if unit.global_position.y < 0:
					var corners = Utils.get_sprite_corners(border)
					
					var min_x = corners[0].x
					var max_x = corners[1].x
					var min_y = corners[0].y
					var max_y = corners[2].y
					var random_x = randf_range(min_x, max_x)
					var random_y = randf_range(min_y, max_y)
					unit.global_position = Vector2(random_x, random_y)
			elif unit is Enemy:
				enemies += 1
		if enemies == 0:
			win()
		elif players == 0:
			lose()
			
func generate_player_units() -> Array:
	var player_arr = []
	
	for unit in GameManager.units:
		var count = GameManager.units[unit]
		if count > 0:
			var scene = GameManager.UNIT[GameManager.Faction.PLAYER][unit]
			var unit_name = GameManager.UnitNames[unit]
			player_arr.append([scene, count, unit_name])
	
	return player_arr
	
func spawnPlayerUnits(player_arr: Array):
	var corners = Utils.get_sprite_corners(border)
	
	var min_x = corners[0].x
	var max_x = corners[1].x
	var min_y = corners[0].y
	var max_y = corners[2].y
	
	for unit_data in player_arr:
		var unit_scene = unit_data[0]  
		var count = unit_data[1]	  
		var unit_type = unit_data[2] if unit_data.size() > 2 else "Unknown Unit" 
		
		for i in range(count):
			var random_x = randf_range(min_x, max_x)
			var random_y = randf_range(min_y, max_y)
			var spawn_position = Vector2(random_x, random_y)
			
			if unit_scene:
				var unit_instance = unit_scene.instantiate()
				add_child(unit_instance)
				unit_instance.global_position = spawn_position
				unit_instance.unit_name = unit_type
				unit_instance.add_to_group("player_units")
			else:
				push_error("No player unit scene provided for spawning")

func spawnEnemyUnits(enemy_arr: Array):
	var corners = Utils.get_sprite_corners(enemy_border)
	
	var min_x = corners[0].x
	var max_x = corners[1].x
	var min_y = corners[0].y
	var max_y = corners[2].y
	
	for enemy_data in enemy_arr:
		var enemy_scene = enemy_data[0] 
		var count = enemy_data[1]
		

		for i in range(count):
			var random_x = randf_range(min_x, max_x)
			var random_y = randf_range(min_y, max_y)
			var spawn_position = Vector2(random_x, random_y)
			
			if enemy_scene:
				var enemy_instance = enemy_scene.instantiate()
				add_child(enemy_instance)
				enemy_instance.global_position = spawn_position
				enemy_instance.add_to_group("enemies")
			else:
				push_error("No enemy scene provided for spawning RAUGH")
			

func spawn_tile_map() -> void:
	# disable all other tilemaps
	const TILE_MAP_LAYER := "TileMapLayer"
	for child in $BiomeMaps.get_children():
		var tilemap_layer = child.find_child(TILE_MAP_LAYER)
		tilemap_layer.enabled = false
		child.visible = false
	print("biome : ", biome)
	var selected_biome
	if biome == PLAINS:
		selected_biome = plains
	elif biome == HILLS:
		selected_biome = hills
	elif biome == MOUNTAINS:
		selected_biome = mountains
	else :
		push_error("Biome : ", biome, " not reconised")
		selected_biome = plains
	active_tile_map = selected_biome.find_child(TILE_MAP_LAYER)
	selected_biome.visible = true
	active_tile_map.enabled = true
	border = selected_biome.find_child("Border")
	enemy_border = selected_biome.find_child("EnemyBorder")
	enemy_border.visible = false

func _on_battle_ui_start_battle():
	if GameManager.get_units(Player).any(func (unit): return unit.held or unit.in_unsafe_place()):
		return
	state = State.BATTLE
	battle_start.emit()
	border.visible = false

func lose():
	battle_lost.emit()
	state = State.POSTGAME
	GameManager.money += int(GameManager.RarityReward["Lost"] * (1 + GameManager.difficulty_score))
	
	await get_tree().create_timer(4).timeout
	GameManager.difficulty_score += GameManager.DIFFICULTY_GAIN_LOSE
	GameManager.end_battle()

func win():
	var reward : String = GameManager.decide_random_reward()
	battle_won.emit(reward)
	if reward == "Common":
		audio.stream = preload("res://sounds/discover.mp3")
	elif reward == "Rare":
		audio.stream = preload("res://sounds/discover_better.mp3")
	elif reward == "Epic":
		audio.stream = preload("res://sounds/discover_best.mp3")
	else:
		print("Hello rarity doesn't exist (I fart)")
	audio.play()
	state = State.POSTGAME
	await get_tree().create_timer(4).timeout
	GameManager.difficulty_score += GameManager.DIFFICULTY_GAIN_WIN
	GameManager.end_battle()

func _on_battle_ui_give_up():
	lose()
