extends Node2D

signal hide_world_ui
signal show_world_ui

var player_view_distance = 3

enum UnitType {
	PEASANT,
	IMP,
	SNAKE,
	GHOST,
	KNIGHT,
	RANGED,
	TANK,
	PRISONER,
	SAW_DEMON,
}
enum RarityType {
	COMMON,
	RARE,
	EPIC,
}


enum Faction {
	PLAYER,
	ENEMY,
	NEUTRAL,
}

const UnitSounds = {
	"Imp" = {
		"attack" : 4,
		"celebrate" : 2,
		"death" : 3,
		"interact" : 2
	},
	"Snake" = {
		"attack" : 3,
		"celebrate" : 2,
		"death" : 3,
		"interact" : 2
	},
	"Peasant" = {
		"attack" : 3,
		"celebrate" : 3,
		"death" : 3,
		"interact" : 2
	},
	"Knight" = {
		"attack" : 4,
		"celebrate" : 2,
		"death" : 3,
		"interact" : 3
	},
	"Ghost" = {
		"attack" : 4,
		"celebrate" : 3,
		"death" : 3,
		"interact" : 3
	},
	"Angel" = {
		"attack" : 4,
		"celebrate" : 2,
		"death" : 3,
		"interact" : 3
	},
	"Prisoner" = {
		"attack" : 3,
		"celebrate" : 2,
		"death" : 3,
		"interact" : 2
	},
	"Gorilla" = {
		"attack" : 3,
		"celebrate" : 2,
		"death" : 2,
		"interact" : 3
	},
	"Arch Angel" = {
		"attack" : 3,
		"celebrate" : 2,
		"death" : 3,
		"interact" : 2
	},
	"Saw Demon" = {
		"attack" : -1,
		"celebrate" : -1,
		"death" : -1,
		"interact" : -1
	}
}

const UNIT = {
	Faction.PLAYER: {
		UnitType.IMP: preload("res://mobs/player/imp.tscn"),
		UnitType.SNAKE: preload("res://mobs/player/snake.tscn"),
		UnitType.GHOST: preload("res://mobs/player/ghost.tscn"),
		UnitType.PRISONER : preload("res://mobs/player/prisoner.tscn"),
		UnitType.SAW_DEMON : preload("res://mobs/player/saw_demon.tscn"),
	},
	Faction.ENEMY: {
		UnitType.PEASANT: preload("res://mobs/enemy/peasent.tscn"),
		UnitType.KNIGHT: preload("res://mobs/enemy/knight.tscn"),
	}
}
# > 0 and <= 100
const MobProbability = {
	"Peasant" : 50,
	"Knight": 10
}

const RarityProbability = {
	"Common": 60, 
	"Rare": 30,
	"Epic": 10,
}

const RarityReward = {
	"Lost": 15, 
	"Common": 45, 
	"Rare": 80,
	"Epic": 200,
}

const MobToSprite = {
	"Flag" : preload("res://art/assets/flags.png"),
	"PathDot" : preload("res://art/assets/path_dot.png"),
	"Player" : preload("res://art/units/darklord.png"),
	"Peasant" : preload("res://art/units/peasant.png"),
	"Knight" : preload("res://art/units/knight.png"),
	"Imp" : preload("res://art/units/imp.png"),
	"Snake" : preload("res://art/units/snake.png"),
	"Ghost" : preload("res://art/units/ghost.png"),
	"Prisoner" : preload("res://art/units/prisoner.png"),
	"Saw Demon" : preload("res://art/units/saw_demon.png"),
}

const MobStats = {
	"Imp": {
		"Hp": 100,
		"Att": 25,
		"MoveSpeed": 80,
		"AttackSpeed": 1,
	},
	"Snake": {
		"Hp": 150,
		"Att": 35,
		"MoveSpeed": 140,
		"AttackSpeed": 1,
	},
	"Ghost": {
		"Hp": 140,
		"Att": 30,
		"MoveSpeed": 160,
		"AttackSpeed": 0.6,
	},
	"Prisoner": {
		"Hp": 250,
		"Att": 60,
		"MoveSpeed": 60,
		"AttackSpeed": 1.5,
	},
	"Saw Demon" : {
		"Hp": 300,
		"Att": 25,
		"MoveSpeed": 80,
		"AttackSpeed": 0.1,
	},
	"Peasant": {
		"Hp": 100,
		"Att": 20,
		"MoveSpeed": 110,
		"AttackSpeed": 1,
	},
	"Knight": {
		"Hp": 300,
		"Att": 20,
		"MoveSpeed": 90,
		"AttackSpeed": 1.4,
	},
	"Angel": {
		"Hp": 200,
		"Att": 45,
		"MoveSpeed": 120,
		"AttackSpeed": 1.1,
	},
	"Gorilla": {
		"Hp": 400,
		"Att": 25,
		"MoveSpeed": 180,
		"AttackSpeed": 1,
	},
	"Arch Angel": {
		"Hp": 250,
		"Att": 70,
		"MoveSpeed": 140,
		"AttackSpeed": 0.8,
	},
}

const DifficultyMult = {
	"Peasant" : 1,
	"Knight" : 1.2,
	"Angel": 1.5,
	"Gorrila": 1.9,
	"ArchAngel": 2.3,
}

var map: Map

var UnitCosts: Dictionary = {UnitType.IMP: 10, \
							UnitType.SNAKE: 25, \
							UnitType.GHOST: 40, \
							UnitType.PRISONER: 60,\
							UnitType.SAW_DEMON: 200,
							
							}
var UnitBasePrice: Dictionary = {UnitType.IMP: 10, \
							UnitType.SNAKE: 25, \
							UnitType.GHOST: 40, \
							UnitType.PRISONER: 60, \
							UnitType.SAW_DEMON: 200,
							
							}

var UnitNames: Dictionary = {UnitType.IMP: "Imp", \
							UnitType.SNAKE: "Snake", \
							UnitType.GHOST: "Ghost", \
							UnitType.PRISONER: "Prisoner", \
							UnitType.SAW_DEMON: "Saw Demon",
							}
#world.tscn generates these
var tiles 
var fogs
#tiles are 2d arrays with [0]=TileData and [1]=local_position

var saved_world: World
var has_generated = false
var map_packed: PackedScene

var difficulty_score = 0.0
const DIFFICULTY_GAIN_WIN = 0.2
const DIFFICULTY_GAIN_LOSE = 0.04
#player vars
var money: int = 100
var units: Dictionary = {UnitType.IMP: 1, \
						 UnitType.SNAKE: 0, \
						 UnitType.GHOST: 0, \
						UnitType.PRISONER: 0, \
						UnitType.SAW_DEMON: 0,
						}

var pre_camera_pos: Vector2
var pre_camera_zoom: Vector2

func _ready() -> void:
	map_packed = load("res://map/map.tscn") as PackedScene

func world_rdy(world: World):
	if not has_generated:
		saved_world = world
		has_generated = true
		saved_world.generate()

func start_battle(mob: Mob, biome : String):
	if mob.mob_name != "Peasant" and mob.mob_name != "Knight":
		return
	hide_world_ui.emit()
	var camera: Camera2D = get_node("/root/World/Camera")
	pre_camera_pos = camera.global_position
	pre_camera_zoom = camera.current_zoom
	camera.zoom = camera.max_zoom
	camera.min_zoom = camera.max_zoom
	camera.global_position = Vector2(700, 300)
	camera.limit_top = -400
	camera.limit_left = -600
	camera.limit_right = 1600
	camera.limit_bottom = 750
	camera.position_smoothing_enabled = false
	get_node("/root/World").process_mode = 4
	get_node("/root/World").hide()
	var map_scene := map_packed.instantiate()
	map_scene.biome = biome
	map_scene.mob = mob
	map_scene.camera = camera
	get_node("/root/").add_child(map_scene)
	saved_world.camera.music.stream = load("res://sounds/demon_battle.mp3")
	saved_world.camera.music.play()

func end_battle():
	get_node("/root/Map").queue_free()
	var camera: Camera2D = get_node("/root/World/Camera")
	camera.position_smoothing_enabled = false
	get_node("/root/World").process_mode = 0
	get_node("/root/World").init_camera()
	get_node("/root/World").show()
	camera.global_position = pre_camera_pos
	camera.current_zoom = pre_camera_zoom
	camera.zoom = pre_camera_zoom
	camera.min_zoom = Vector2(0.45, 0.45)
	show_world_ui.emit()
	saved_world.camera.music.stream = load("res://sounds/world_music.mp3")
	saved_world.camera.music.play()

func get_units(type):
	if map == null:
		return []
	var units: Array = []
	for i in map.get_children():
		if is_instance_of(i, type):
			units.push_back(i)
	return units

func decide_random_mob() -> String:
	var total_weight = 0
	for mob in MobProbability.keys():
		total_weight += MobProbability[mob]
	var random_value = randi() % total_weight
	for mob in MobProbability.keys():
		random_value -= MobProbability[mob]
		if random_value < 0:
			return mob
	return ""

func decide_random_reward() -> String:
	var total_weight = 0
	for rarity in RarityProbability.keys():
		total_weight += RarityProbability[rarity]
	var random_value = randi() % total_weight
	for rarity in RarityProbability.keys():
		random_value -= RarityProbability[rarity]
		if random_value < 0:
			money += int(RarityReward[rarity] * (1 + difficulty_score))
			return rarity
	return ""

func ui_unit_bought():
	saved_world.instantiate_entourage()

const PEASENT := preload("res://mobs/enemy/peasent.tscn")
const KNIGHT = preload("res://mobs/enemy/knight.tscn")
const ANGEL = preload("res://mobs/enemy/angel.tscn")
const GORILLA = preload("res://mobs/enemy/gorilla.tscn")
const ARCH_ANGEL = preload("res://mobs/enemy/arch_angel.tscn")

func generate_enemies(mob) -> Array:
	var output = []
	var real_score = difficulty_score * DifficultyMult[mob.mob_name]

	var tier1 = [PEASENT, SpawnRate.t1(real_score)]  # Weakest 
	var tier2 = [KNIGHT, SpawnRate.t2(real_score)]
	var tier3 = [ANGEL, SpawnRate.t3(real_score)]
	var tier4 = [GORILLA, SpawnRate.t4(real_score)]
	var tier5 = [ANGEL, SpawnRate.t5(real_score)]
	var tier6 = [ARCH_ANGEL, SpawnRate.t6(real_score)]  # Strongest 
	
	output = [
		tier1,
		tier2,
		tier3,
		tier4,
		tier5,
		tier6,
	]
	
	var filtered_output = []
	for entry in output:
		if entry[1] > 0:
			filtered_output.append(entry)
	if difficulty_score >= SpawnRate.get_max_diff():
		filtered_output = [[ARCH_ANGEL,10]]
	return filtered_output

func calc_price(n : int) -> int:
	return 2**(n*0.25)
