class_name Gorrila extends Enemy

var speed
var life
var attack
@onready var map: Map = get_parent()
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var walking : bool  = false
var celebrating : bool = false
var can_attack : bool = true

func _ready() -> void:
	super()
	unit_name = "Gorrila"
	life = GameManager.MobStats[unit_name]["Hp"]
	attack = GameManager.MobStats[unit_name]["Att"]
	speed = GameManager.MobStats[unit_name]["MoveSpeed"]
	$AttackTimer.wait_time = GameManager.MobStats[unit_name]["AttackSpeed"]
	tween_controller.original_sprite_scale = $Sprite.scale

func _physics_process(delta: float) -> void:
	z_index = position.y # sets the position so units are positons infront eachother forstaar du
	if map.state == map.State.POSTGAME and !celebrating:
		celebrating = true
		tween_controller.celebrate()
		audio_controller.play_random_sound_of_type("celebrate", unit_name)
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
	navigation_agent.target_position = closest_player.global_position
	var dir = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()
	var collider: KinematicCollision2D = get_last_slide_collision()
	if !walking:
		tween_controller.walk(true)
		walking = true
	if collider:
		if collider.get_collider() is Player:
			if can_attack:
				can_attack = false
				$AttackTimer.start()
				audio_controller.play_random_sound_of_type("attack", unit_name)
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
