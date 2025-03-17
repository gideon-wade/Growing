class_name Map extends Node2D

enum State {
	PREGAME,
	BATTLE,
	POSTGAME
}

var state = State.PREGAME

func _on_ready() -> void:
	GameManager.map = self

func _process(delta: float) -> void:
	var players = 0
	var enemies = 0
	for unit in get_children():
		if unit is Player:
			players += 1
		elif unit is Enemy:
			enemies += 1
	if enemies == 0:
		$Label.text = "You win"
		$Label.visible = true
		state = State.POSTGAME
		await get_tree().create_timer(1.5).timeout
		GameManager.end_battle()
	elif players == 0:
		$Label.text = "You lose"
		$Label.visible = true
		state = State.POSTGAME

func _on_button_pressed() -> void:
	$Button.queue_free()
	state = State.BATTLE
