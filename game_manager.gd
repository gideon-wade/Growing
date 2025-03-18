extends Node2D

enum UnitType {
	PEASENT,
	IMP,
	IMPT,
	KNIGHT,
	RANGED,
	TANK,
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
	"Impt" = {
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
		UnitType.IMPT: preload("res://mobs/player/impt.tscn")
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
const MobToSprite = {
	"Flag" : preload("res://art/assets/flags.png"),
	"PathDot" : preload("res://art/assets/path_dot.png"),
	"Player" : preload("res://art/units/darklord.png"),
	"Peasant" : preload("res://art/units/peasant.png"),
	"Knight" : preload("res://art/units/knight.png"),
}


var map: Map

#world.tscn generates these
var tiles 
#tiles are 2d arrays with [0]=TileData and [1]=local_position

var saved_world: World
var has_generated = false
var map_packed: PackedScene

func _ready() -> void:
	map_packed = load("res://Map/map.tscn") as PackedScene

func world_rdy(world: World):
	if not has_generated:
		saved_world = world
		has_generated = true
		saved_world.generate()

func start_battle(mob: Mob):
	if mob.mob_name != "Peasant":
		return
	get_node("/root/World").process_mode = 4
	get_node("/root/World").hide()
	get_viewport().canvas_transform = Transform2D.IDENTITY
	get_node("/root/").add_child(map_packed.instantiate())
	

func end_battle():
	get_node("/root/Map").queue_free()
	get_node("/root/World").process_mode = 0
	get_node("/root/World").show()

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
