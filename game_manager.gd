extends Node2D

signal hide_world_ui
signal show_world_ui

var player_view_distance = 3

enum UnitType {
	PEASENT,
	IMP,
	SNAKE,
	GHOST,
	KNIGHT,
	RANGED,
	TANK,
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
	"Peasent" = {
		"attack" : 3,
		"celebrate" : 3,
		"death" : 3,
		"interact" : 0
	},
	"Knight" = {
		"attack" : 0,
		"celebrate" : 0,
		"death" : 0,
		"interact" : 0
	},
	"Ghost" = {
		"attack" : 0,
		"celebrate" : 0,
		"death" : 0,
		"interact" : 0
	}
}

const UNIT = {
	Faction.PLAYER: {
		UnitType.IMP: preload("res://mobs/player/imp.tscn"),
		UnitType.SNAKE: preload("res://mobs/player/snake.tscn"),
		UnitType.GHOST: preload("res://mobs/player/imp.tscn"),
	},
	Faction.ENEMY: {
		UnitType.PEASENT: preload("res://mobs/enemy/peasent.tscn")
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
	"Common": 15, 
	"Rare": 30,
	"Epic": 100,
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
}


var map: Map

var UnitCosts: Dictionary = {UnitType.IMP: 10, \
							UnitType.SNAKE: 25, \
							UnitType.GHOST: 40,
							}

var UnitNames: Dictionary = {UnitType.IMP: "Imp", \
							UnitType.SNAKE: "Snake", \
							UnitType.GHOST: "Ghost",
							}
#world.tscn generates these
var tiles 
var fogs
#tiles are 2d arrays with [0]=TileData and [1]=local_position

var saved_world: World
var has_generated = false
var map_packed: PackedScene

#player vars
var money: int = 100
var units: Dictionary = {UnitType.IMP: 2, \
						 UnitType.SNAKE: 0, \
						 UnitType.GHOST: 0}

func _ready() -> void:
	map_packed = load("res://Map/map.tscn") as PackedScene

func world_rdy(world: World):
	if not has_generated:
		saved_world = world
		has_generated = true
		saved_world.generate()

func start_battle(mob: Mob, biome : String):
	if mob.mob_name != "Peasant":
		return
	hide_world_ui.emit()
	get_node("/root/World").process_mode = 4
	get_node("/root/World").hide()
	get_viewport().canvas_transform = Transform2D.IDENTITY
	var map_scene := map_packed.instantiate()
	map_scene.biome = biome
	get_node("/root/").add_child(map_scene)
	

func end_battle():
	get_node("/root/Map").queue_free()
	get_node("/root/World").process_mode = 0
	get_node("/root/World").show()
	show_world_ui.emit()

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
			money += RarityReward[rarity]
			return rarity
	return ""

func ui_unit_bought():
	saved_world.instantiate_entourage()
