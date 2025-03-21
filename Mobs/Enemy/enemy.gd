class_name Enemy extends CharacterBody2D

var is_alive : bool = true
@onready var tween_controller: TweenController = $TweenController
@onready var audio_controller: AudioController = $AudioController
var unit_name : String
var attack_speed : float = 0.6

func _ready() -> void:
	tween_controller.original_sprite_scale = Vector2(0.25, 0.25)
	$AttackTimer.wait_time = attack_speed
