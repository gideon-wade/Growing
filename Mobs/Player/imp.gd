class_name Imp extends Player

const SPEED = 80

var life = 100
var attack = 25
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var walking : bool  = false
var celebrating : bool = false
var can_attack : bool = true

func _ready() -> void:
	super()
	map = get_parent()
	unit_name = "Imp"
	tween_controller.original_sprite_scale = $Sprite.scale

func _physics_process(delta: float) -> void:
	z_index = position.y # sets the position so units are positons infront eachother forstaar du
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
	navigation_agent.target_position = closest_enemy.global_position
	var dir = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = dir * SPEED
	move_and_slide()
	var collider: KinematicCollision2D = get_last_slide_collision()
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
