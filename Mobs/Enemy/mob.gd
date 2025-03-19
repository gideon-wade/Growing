class_name Mob extends Node2D

var mob_name : String
@onready var sprite: Sprite2D = $Sprite
@onready var tween_controller: TweenController = $TweenController
@onready var audio_controller: Node = $AudioController
var is_player : bool = false
var pos : Vector2i 
var fog : TileMapLayer
var has_been_revealed : bool = false

func _process(delta : float) -> void:
	if !has_been_revealed && is_player:
		has_been_revealed = true
	if !has_been_revealed:
		if pos && !is_player:
			if fog.get_cell_tile_data(pos) != null:
				self.visible = true
				has_been_revealed = true
