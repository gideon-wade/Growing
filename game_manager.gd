extends Node2D

enum UnitType {
	BASIC,
	RANGED,
	TANK,
}

enum Faction {
	PLAYER,
	ENEMY,
	NEUTRAL,
}

const UNIT = {
	Faction.PLAYER: {
		UnitType.BASIC: preload("res://mobs/player/basic_player.tscn")
	},
	Faction.ENEMY: {
		UnitType.BASIC: preload("res://mobs/enemy/basic_enemy.tscn")
	}
}
# > 0 and <= 100
const MobProbability = {
	"Peasant" : 50,
	"Knight": 10
}
const MobToSprite = {
	"Player" : preload("res://art/units/darklord.png"),
	"Peasant" : preload("res://art/units/peasant.png"),
	"Knight" : preload("res://art/units/knight.png"),
}


var map: Map

#world.tscn generates these
var tiles 
#tiles are 2d arrays with [0]=TileData and [1]=local_position

var world

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
