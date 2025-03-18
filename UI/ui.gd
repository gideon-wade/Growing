extends Control
@onready var canvas_layer = $CanvasLayer

func _ready():
	GameManager.hide_world_ui.connect(func() : canvas_layer.visible = false)
	GameManager.show_world_ui.connect(func() : canvas_layer.visible = true)
