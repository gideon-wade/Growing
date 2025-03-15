extends Node2D

@export var unit_type: int = GameManager.UnitType.BASIC
@export var faction: int = GameManager.Faction.PLAYER

func _on_timer_timeout() -> void:
	var unit = GameManager.UNIT[faction][unit_type].instantiate()
	unit.position = global_position
	get_parent().add_child(unit)
