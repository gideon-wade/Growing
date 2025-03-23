extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(30):
		GameManager.difficulty_score += 0.3
		print(GameManager.generate_enemies())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	pass
