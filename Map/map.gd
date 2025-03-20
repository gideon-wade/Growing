class_name Map extends Node2D
@onready var audio: AudioStreamPlayer2D = $Audio

enum State {
	PREGAME,
	BATTLE,
	POSTGAME
}

var state = State.PREGAME
@onready var spawn_points = {GameManager.UnitType.IMP: [$ImpSpawn],
							GameManager.UnitType.SNAKE: [$SnakeSpawn],
							GameManager.UnitType.GHOST: [$GhostSpawn],
							}

func _on_ready() -> void:
	GameManager.map = self
	spawnPlayerUnits()

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
			$Camera2D/RewardLabel.visible = true
			if reward == "Common":
				$Camera2D/RewardLabel.text = "You got a Common reward."
				audio.stream = preload("res://sounds/discover.mp3")
			elif reward == "Rare":
				$Camera2D/RewardLabel.text = "WOW You got a RARE reward!"
				audio.stream = preload("res://sounds/discover_better.mp3")
			elif reward == "Epic":
				$Camera2D/RewardLabel.text = "OOOOKAAAAAAAY YOU GOT AN EPIC REWARD!! (crazy)"
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

func spawnPlayerUnits():
	for unit in GameManager.units:
		for amount in range(GameManager.units[unit]):
			var unit_scene = GameManager.UNIT[GameManager.Faction.PLAYER][unit].instantiate()
			var spawn_point: Marker2D = spawn_points[unit].pick_random()
			unit_scene.global_position = spawn_point.global_position + Vector2(randf(), randf())
			unit_scene.unit_name = GameManager.UnitNames[unit]
			add_child(unit_scene)


func _on_button_pressed() -> void:
	$Button.queue_free()
	state = State.BATTLE
