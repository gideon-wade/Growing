class_name TweenController extends Node

signal has_attacked

var original_sprite_state : Vector2i
var unit_sprite : Sprite2D
var unit_tween : Tween
var projectile_tween : Tween
var unit_position : Vector2
var unit_walking : bool
var original_sprite_scale : Vector2
@onready var audio_controller: AudioController = $"../AudioController"

func _ready() -> void:
	original_sprite_state = $"../Sprite".position
	unit_sprite = $"../Sprite"

func idle(wait=false) -> void:
	reset()
	if wait:
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
	unit_tween = create_tween().set_loops() #Loops until cancelled
	# Move in V shape (represents breathing animation)
	var unit_scale = unit_sprite.scale
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + Vector2(0.01, -0.01), 0.2)
	unit_tween.parallel().tween_property(unit_sprite, "rotation", unit_sprite.rotation + 0.01, 0.2)
	unit_tween.parallel().tween_property(unit_sprite, "scale", unit_scale - Vector2(-0.01, 0.01), 0.2)
	
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position, 0.5)
	unit_tween.parallel().tween_property(unit_sprite, "rotation", unit_sprite.rotation - 0.01, 0.5)
	unit_tween.parallel().tween_property(unit_sprite, "scale", unit_scale, 0.5)
	
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + Vector2(0.01, -0.01), 0.2)
	unit_tween.parallel().tween_property(unit_sprite, "rotation", unit_sprite.rotation + 0.01, 0.2)
	unit_tween.parallel().tween_property(unit_sprite, "scale", unit_scale - Vector2(-0.01, 0.01), 0.2)
	
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position, 0.5)
	unit_tween.parallel().tween_property(unit_sprite, "rotation", unit_sprite.rotation + 0.01, 0.5)
	unit_tween.parallel().tween_property(unit_sprite, "scale", unit_scale, 0.5)

func walk(wait=false) -> void:
	reset()
	if wait:
		await get_tree().create_timer(randf_range(0.05, 0.2)).timeout
		
	unit_tween = create_tween().set_loops()
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + Vector2(0.00, 5), 0.1)
	unit_tween.parallel().tween_property(unit_sprite, "rotation", 0.05, 0.1)
	
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + Vector2(0.00, -5), 0.1)
	unit_tween.parallel().tween_property(unit_sprite, "rotation", 0.10, 0.1)
	
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + Vector2(0.00, 5), 0.1)
	unit_tween.parallel().tween_property(unit_sprite, "rotation", -0.05, 0.1)
	
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position - Vector2(0.00, 5), 0.1)
	unit_tween.parallel().tween_property(unit_sprite, "rotation", -0.10, 0.1)

func light_melee_attack(unit_pos : Vector2i, clickedTile : Vector2i) -> void:
	reset()
	unit_tween = create_tween()
	unit_position = unit_sprite.position
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + \
		  20 * Vector2(clickedTile - unit_pos), 0.2). \
		  set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await unit_tween.finished
	has_attacked.emit()

func heavy_melee_attack(unit_pos : Vector2i, clickedTile : Vector2i) -> void:
	reset()
	unit_tween = create_tween()
	unit_position = unit_sprite.position
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position - \
		  20 * Vector2(clickedTile - unit_pos), 0.5). \
		  set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await unit_tween.finished
	unit_tween = create_tween()
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + \
		  20 * Vector2(clickedTile - unit_pos), 0.2). \
		  set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	has_attacked.emit()


func ranged_attack(unit_pos : Vector2i, clickedTile : Vector2i) -> void:
	reset()
	unit_tween = create_tween()
	unit_position = unit_sprite.position
	var normalized_difference : Vector2 = Vector2(clickedTile - unit_pos).normalized()
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + \
		  20 * normalized_difference, 0.2). \
		  set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	has_attacked.emit()
	
func fire_projectile(unit_pos : Vector2, target_tile : Vector2i, projectile_texture : CompressedTexture2D) -> void:
	projectile_tween = create_tween()
	var projectile := TextureRect.new()
	projectile.texture = projectile_texture
	add_child(projectile)
	projectile.position = unit_pos
	projectile.rotation = unit_pos.direction_to(Vector2(target_tile)).angle()
	projectile.scale = Vector2(2, 2)
	projectile_tween.tween_property(projectile, "position", \
		Vector2(target_tile), 1.0).set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN)
	projectile_tween.parallel().tween_property(projectile, "scale", \
		projectile.scale + Vector2(2.5, 0), 1.0).set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN)
	await projectile_tween.finished
	
	remove_child(projectile)
	
func step_back() -> void:
	reset()
	unit_tween = create_tween()
	unit_tween.tween_property(unit_sprite, "position", unit_position, 0.2).\
		set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await unit_tween.finished
	idle()

func hit(attackingUnit : Unit, unitHit : Unit) -> void:
	reset()
	unit_tween = create_tween()
	var normalized_difference := Vector2(attackingUnit.global_position - \
		unitHit.global_position).normalized()
	var unit_scale := unit_sprite.scale
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position - \
		20 * normalized_difference, 0.1).set_trans(Tween.TRANS_EXPO).\
		set_ease(Tween.EASE_IN)
	unit_tween.parallel().tween_property(unit_sprite, "scale", unit_scale + \
		Vector2(0.1, -0.1), 0.2)
	unit_tween.tween_property(unit_sprite, "position", unit_sprite.position, 0.2)
	unit_tween.parallel().tween_property(unit_sprite, "scale", unit_scale, 0.2)
	await unit_tween.finished
	walk(true)

func die() -> void:
	reset()
	unit_tween = create_tween()
	unit_tween.tween_property(unit_sprite, "rotation", PI/2, 0.5).set_trans(Tween.TRANS_EXPO).\
 		set_ease(Tween.EASE_OUT)
	unit_tween.tween_property(unit_sprite, "modulate", \
 		Color(unit_sprite.modulate.r, unit_sprite.modulate.g, \
 		unit_sprite.modulate.b, 0.0), \
 		audio_controller._sounds["dead"].get_length() - 0.1)

func celebrate() -> void:
	reset()
	await get_tree().create_timer(randf_range(0.05, 0.3)).timeout
	while true:
		unit_tween = create_tween()
		unit_tween.tween_property(unit_sprite, "position", unit_sprite.position - \
			  Vector2(0, 20), 0.25). \
			  set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		await unit_tween.finished
		unit_tween = create_tween()
		unit_tween.tween_property(unit_sprite, "rotation", PI/16, 0.1)
		await unit_tween.finished
		unit_tween = create_tween()
		unit_tween.tween_property(unit_sprite, "rotation", -PI/16, 0.1)
		await unit_tween.finished
		unit_tween = create_tween()
		unit_tween.tween_property(unit_sprite, "rotation", 0, 0.1)
		await unit_tween.finished
		unit_tween = create_tween()
		unit_tween.tween_property(unit_sprite, "position", unit_sprite.position + \
			  Vector2(0, 20), 0.25). \
			  set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await unit_tween.finished

func reset() -> void:
	if unit_tween:
		unit_tween.kill() # Stop the tween if it's running
	unit_sprite.rotation = 0.0
	unit_sprite.scale = original_sprite_scale
	
