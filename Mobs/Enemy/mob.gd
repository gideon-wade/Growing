class_name Mob extends Node2D

var mob_name : String
@onready var sprite: Sprite2D = $Sprite
@onready var tween_controller: TweenController = $TweenController
@onready var audio_controller: Node = $AudioController
