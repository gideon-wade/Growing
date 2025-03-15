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
		UnitType.BASIC: preload("res://Mobs/Player/basic_player.tscn")
	},
	Faction.ENEMY: {
		UnitType.BASIC: preload("res://Mobs/Enemy/basic_enemy.tscn")
	}
}

var map: Map

func get_units(type):
	if map == null:
		return []
	var units: Array = []
	for i in map.get_children():
		if is_instance_of(i, type):
			units.push_back(i)
	
	return units
	
