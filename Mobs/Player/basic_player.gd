class_name BasicPlayer extends Player

const SPEED = 100

var life = 100
var attack = 25
@onready var map: Map = get_parent()
var walking : bool  = false
var celebrating : bool = false
var can_attack : bool = true

func _physics_process(delta: float) -> void:
	if map.state == map.State.POSTGAME and !celebrating:
		celebrating = true
		tween_controller.celebrate()
		audio_controller.play_random_sound_of_type("celebrate", unit_name)
	if map.state != map.State.BATTLE or !is_alive:
		return
	var enemies: Array = GameManager.get_units(Enemy)
	if enemies.size() == 0:
		return
	var closest_enemy: Enemy = null
	var min_dist = INF
	for enemy: Enemy in enemies:
		var dist = position.distance_squared_to(enemy.position)
		if dist < min_dist and enemy.is_alive:
			closest_enemy = enemy
			min_dist = dist
	if closest_enemy == null:
		return
	var angle = position.angle_to_point(closest_enemy.position)
	var collider: KinematicCollision2D = move_and_collide(Vector2(cos(angle), sin(angle)))
	if !walking:
		tween_controller.walk(true)
		walking = true
	if collider:
		if collider.get_collider() is Enemy:
			if can_attack:
				can_attack = false
				audio_controller.play_random_sound_of_type("attack", unit_name)
				$AttackTimer.start()
				collider.get_collider().damage(attack)

func damage(dmg):
	life -= dmg
	$Label.text = str(life)
	if life <= 0:
		is_alive = false
		$CollisionShape2D.disabled = true
		self.z_index = -1
		tween_controller.die()
		audio_controller.play_random_sound_of_type("death", unit_name)
		await tween_controller.unit_tween.finished
		queue_free()

func _on_attack_timer_timeout() -> void:
	can_attack = true 
