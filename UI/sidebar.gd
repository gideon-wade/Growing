extends HBoxContainer

@onready var sidebar = $Panel
@onready var units_button = $Control2
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_button_pressed():
	sidebar.visible = false
	units_button.visible = true


func _on_units_button_pressed():
	sidebar.visible = true
	units_button.visible = false
