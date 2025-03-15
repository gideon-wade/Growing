class_name BasicPlayer extends Player

const SPEED = 100

var life = 100
var attack = 25
@onready var map: Map = get_parent()

func _physics_process(delta: float) -> void:
	if map.state != map.State.BATTLE:
		return
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
	var collider: KinematicCollision2D = move_and_collide(Vector2(cos(angle), sin(angle)))
	if collider:
		if collider.get_collider() is Enemy:
			collider.get_collider().damage(attack)

func damage(dmg):
	life -= dmg
	$Label.text = str(life)
	if life <= 0:
		queue_free()
