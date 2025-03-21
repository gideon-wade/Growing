extends Control

signal start_battle
signal give_up

@export var map: Map
@onready var label = $CanvasLayer/Control/VBoxContainer/HBoxContainer/Control2/VBoxContainer/Panel/VBoxContainer/Label
@onready var panel = $CanvasLayer/Control/VBoxContainer/HBoxContainer/Control2/VBoxContainer/Panel
@onready var reward_label = $CanvasLayer/Control/VBoxContainer/HBoxContainer/Control2/VBoxContainer/Panel/VBoxContainer/MarginContainer/RewardLabel
@onready var start_button = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/Control3/Button
@onready var give_up_button = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/Control/Button
@onready var timer = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/Control/Timer
func _ready():
	map.battle_won.connect(_on_battle_won)
	map.battle_lost.connect(_on_battle_lost)
	map.battle_start.connect(_on_battle_start)
	panel.visible = false
	
func _on_battle_won(reward : String):
	panel.visible = true
	label.text = "You win"
	label.visible = true
	reward_label.visible = true
	give_up_button.visible = false
	var money = GameManager.RarityReward[reward]
	if reward == "Common":
		reward_label.text = "You got a common reward.\nReward: " + str(money) + " $"
	elif reward == "Rare":
		reward_label.text = "You got a Rare reward!\nReward: " + str(money) + " $"
	elif reward == "Epic":
		reward_label.text = "You got an EPIC reward!\nReward: " + str(money) + " $"
	else:
		print("Hello rarity doesn't exist (I fart)")

func _on_battle_lost():
	var money = GameManager.RarityReward["Lost"]
	label.text = "You lose\nReward: " + str(money) + " $"
	panel.visible = true
	give_up_button.visible = false

func _on_button_pressed():
	start_battle.emit()
	start_button.visible = false

func _on_battle_start():
	timer.start()

func _on_timer_timeout():
	if map.state != map.State.POSTGAME:
		give_up_button.visible = true


func _on_give_up_button_pressed():
	give_up.emit()
