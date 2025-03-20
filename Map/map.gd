class_name Map extends Node2D
@onready var audio: AudioStreamPlayer2D = $Audio

enum State {
	PREGAME,
	BATTLE,
	POSTGAME
}

var state = State.PREGAME

func _on_ready() -> void:
	GameManager.map = self

func _process(delta: float) -> void:
	if state != State.POSTGAME:
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
			var reward : String = GameManager.decide_random_reward()
			var reward_label = $Camera2D/CanvasLayer/RewardLabel
			reward_label.visible = true
			if reward == "Common":
				reward_label.text = "You got a Common reward."
				audio.stream = preload("res://sounds/discover.mp3")
			elif reward == "Rare":
				reward_label.text = "WOW You got a RARE reward!"
				audio.stream = preload("res://sounds/discover_better.mp3")
			elif reward == "Epic":
				reward_label.text = "OOOOKAAAAAAAY YOU GOT AN EPIC REWARD!! (crazy)"
				audio.stream = preload("res://sounds/discover_best.mp3")
			else:
				print("Hello rarity doesn't exist (I fart)")
			audio.play()
			state = State.POSTGAME
			await get_tree().create_timer(4).timeout
			GameManager.end_battle()
		elif players == 0:
			$Label.text = "You lose"
			$Label.visible = true
			state = State.POSTGAME
			await get_tree().create_timer(4).timeout
			GameManager.end_battle()

func _on_button_pressed() -> void:
	$Button.queue_free()
	state = State.BATTLE
