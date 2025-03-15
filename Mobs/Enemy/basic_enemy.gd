class_name BasicEnemy extends Enemy

const SPEED = 100

var life = 100
var attack = 40

func _process(delta: float) -> void:
	var players: Array = GameManager.get_players()
	if players.size() == 0:
		return
	var closest_player: Player = null
	var min_dist = INF
	for player: Player in players:
		var dist = self.position.distance_squared_to(player.position)
		if dist < min_dist:
			closest_player = player
			min_dist = dist
	
	var angle = position.angle_to_point(closest_player.position)

	move_and_collide(Vector2(cos(angle), sin(angle)))

func damage(dmg):
	life -= dmg
	if life <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.damage(attack)
