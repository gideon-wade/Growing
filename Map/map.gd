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

const PLAINS = "plains"
const HILLS = "hills"
const MOUNTAINS = "mountains"

var active_tile_map : TileMapLayer

func _on_ready() -> void:
	GameManager.map = self
	spawn_tile_map()
	spawnPlayerUnits()
	spawnEnemyUnits()

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
			elif unit is Enemy:
				enemies += 1
		if enemies == 0:
			win()
		elif players == 0:
			lose()
			

func spawnPlayerUnits():
	for unit in GameManager.units:
		for amount in range(GameManager.units[unit]):
			var unit_scene = GameManager.UNIT[GameManager.Faction.PLAYER][unit].instantiate()
			var spawn_point: Marker2D = spawn_points[unit].pick_random()
			unit_scene.global_position = spawn_point.global_position + Vector2(randf(), randf())
			unit_scene.unit_name = GameManager.UnitNames[unit]
			add_child(unit_scene)

func spawnEnemyUnits():
	pass

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
	
func _on_button_pressed() -> void:
	#$Camera2D/CanvasLayer/Button.queue_free()
	state = State.BATTLE


func _on_battle_ui_start_battle():
	state = State.BATTLE
	battle_start.emit()

func lose():
	battle_lost.emit()
	state = State.POSTGAME
	GameManager.money += GameManager.RarityReward["Lost"]
	
	await get_tree().create_timer(4).timeout
	GameManager.difficulty_score += 20
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
	GameManager.difficulty_score += 60
	GameManager.end_battle()

func _on_battle_ui_give_up():
	lose()
