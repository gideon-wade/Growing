class_name BasicEnemy extends Enemy

const SPEED = 100

var life = 100
var attack = 20
@onready var map: Map = get_parent()

func _process(delta: float) -> void:
	if map.state != map.State.BATTLE:
		return
	var players: Array = GameManager.get_units(Player)
	if players.size() == 0:
		return
	var closest_player: Player = null
	var min_dist = INF
	for player: Player in players:
		var dist = position.distance_squared_to(player.position)
		if dist < min_dist:
			closest_player = player
			min_dist = dist
	
	var angle = position.angle_to_point(closest_player.position)
	var collider: KinematicCollision2D = move_and_collide(Vector2(cos(angle), sin(angle)))
	if collider:
		if collider.get_collider() is Player:
			collider.get_collider().damage(attack)

func damage(dmg):
	life -= dmg
	$Label.text = str(life)
	if life <= 0:
		queue_free()
