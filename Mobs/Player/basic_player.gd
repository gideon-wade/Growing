class_name BasicPlayer extends Player

const SPEED = 100

var life = 100
var attack = 10

func _process(delta: float) -> void:
	var enemies: Array = GameManager.get_units(Enemy)
	if enemies.size() == 0:
		return
	var closest_enemy: Enemy = null
	var min_dist = INF
	for enemy: Enemy in enemies:
		var dist = position.distance_squared_to(enemy.position)
		if dist < min_dist:
			closest_enemy = enemy
			min_dist = dist
	
	var angle = position.angle_to_point(closest_enemy.position)
	move_and_collide(Vector2(cos(angle), sin(angle)))

func damage(dmg):
	life -= dmg
	if life <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		body.damage(attack)
