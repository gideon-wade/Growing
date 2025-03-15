extends Node2D

var map: Map

func get_enemies():
	if map == null:
		return []
	var enemies: Array[Enemy] = []
	for i in map.get_children():
		if i is Enemy:
			enemies.push_back(i)
	
	return enemies

func get_players():
	if map == null:
		return []
	var players: Array[Player] = []
	for i in map.get_children():
		if i is Player:
			players.push_back(i)
	
	return players
