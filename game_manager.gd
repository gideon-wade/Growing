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

var map: Map

#world.tscn generates these
var tiles 
#tiles are 2d arrays with [0]=TileData and [1]=local_position

func get_units(type):
	if map == null:
		return []
	var units: Array = []
	for i in map.get_children():
		if is_instance_of(i, type):
			units.push_back(i)
	
	return units
	
