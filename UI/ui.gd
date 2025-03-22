extends Control
@onready var canvas_layer = $CanvasLayer
@onready var sidebar: HBoxContainer = $CanvasLayer/Control/Sidebar

func _ready():
	GameManager.hide_world_ui.connect(func() : canvas_layer.visible = false)
	GameManager.show_world_ui.connect(func() : canvas_layer.visible = true)
	get_parent().info_shown = true
	print("info shown ", get_parent().info_shown)
