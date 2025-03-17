class_name BasicEnemy extends Enemy

const SPEED = 100

var life = 100
var attack = 20
@onready var map: Map = get_parent()
var walking : bool  = false
var celebrating : bool = false
var can_attack : bool = true

func _physics_process(delta: float) -> void:
	if map.state == map.State.POSTGAME and !celebrating:
		celebrating = true
		tween_controller.celebrate()
		
	if map.state != map.State.BATTLE or !is_alive:
		return
	var players: Array = GameManager.get_units(Player)
	if players.size() == 0:
		return
	var closest_player: Player = null
	var min_dist = INF
	for player: Player in players:
		var dist = position.distance_squared_to(player.position)
		if dist < min_dist && player.is_alive:
			closest_player = player
			min_dist = dist
	if closest_player == null:
		return
	var angle = position.angle_to_point(closest_player.position)
	var collider: KinematicCollision2D = move_and_collide(Vector2(cos(angle), sin(angle)))
	if !walking:
		tween_controller.walk(true)
		walking = true
	if collider:
		if collider.get_collider() is Player:
			if can_attack:
				$AttackTimer.start()
				can_attack = false
				collider.get_collider().damage(attack)

func damage(dmg):
	life -= dmg
	$Label.text = str(life)
	if life <= 0:
		is_alive = false
		$CollisionShape2D.disabled = true
		self.z_index = -1
		tween_controller.die()
		await tween_controller.unit_tween.finished
		queue_free()

func _on_attack_timer_timeout() -> void:
	can_attack = true
