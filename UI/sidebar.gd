class_name Sidebar extends HBoxContainer

@onready var sidebar = $Panel
@onready var units_button = $Control2
@onready var info = $Control/MarginContainer

@onready var money_label: Label = $Panel/VBoxContainer2/HBoxContainer3/Label
@onready var imp_amount: Label = $Panel/VBoxContainer2/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/Label2
@onready var snake_amount: Label = $Panel/VBoxContainer2/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer2/Label2
@onready var ghost_amount: Label = $Panel/VBoxContainer2/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer4/Label2

@onready var imp_cost: Label = $Panel/VBoxContainer2/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var snake_cost: Label = $Panel/VBoxContainer2/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer2/Label
@onready var ghost_cost: Label = $Panel/VBoxContainer2/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer4/Label

var world

signal unit_bought

# Called when the node enters the scene tree for the first time.
func _ready():
	
	sidebar.visible = false
	units_button.visible = true
	
	imp_cost.text = str(GameManager.UnitCosts[GameManager.UnitType.IMP]) + "$"
	snake_cost.text = str(GameManager.UnitCosts[GameManager.UnitType.SNAKE]) + "$"
	ghost_cost.text = str(GameManager.UnitCosts[GameManager.UnitType.GHOST]) + "$"
	
	unit_bought.connect(GameManager.ui_unit_bought)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	money_label.text = "Money: " + str(GameManager.money) + " $"
	imp_amount.text = str(GameManager.units[GameManager.UnitType.IMP])
	snake_amount.text = str(GameManager.units[GameManager.UnitType.SNAKE])
	ghost_amount.text = str(GameManager.units[GameManager.UnitType.GHOST])


func _on_back_button_pressed():
	sidebar.visible = false
	units_button.visible = true


func _on_units_button_pressed():
	sidebar.visible = true
	units_button.visible = false

func buy(unit_type):
	if GameManager.money >= GameManager.UnitCosts[unit_type]:
		GameManager.money -= GameManager.UnitCosts[unit_type]
		GameManager.units[unit_type] += 1
		unit_bought.emit()

func _on_buy_imp() -> void:
	buy(GameManager.UnitType.IMP)

func _on_but_snake() -> void:
	buy(GameManager.UnitType.SNAKE)

func _on_button_pressed() -> void:
	buy(GameManager.UnitType.GHOST)

func _on_hide_info_button_pressed():
	info.visible = false
	world.info_shown = false

func _on_info_button_pressed():
	info.visible = true
	world.info_shown = true
