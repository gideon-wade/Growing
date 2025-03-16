class_name Enemy extends RigidBody2D

var is_alive : bool = true
@onready var tween_controller: TweenController = $TweenController
@onready var audio_controller: AudioController = $AudioController

func _ready() -> void:
	tween_controller.original_sprite_scale = Vector2(0.25, 0.25)
	var unit_sounds = {
		"dead" : preload("res://sounds/dead.mp3")
	}
	audio_controller.set_unit_sounds(unit_sounds)
