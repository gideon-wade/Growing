class_name Map extends Node2D

func _on_ready() -> void:
	GameManager.map = self
	print("Set game")
