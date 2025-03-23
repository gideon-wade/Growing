class_name Player extends CharacterBody2D

var held = false
@onready var sprite: Sprite2D = $Sprite
@onready var tween_controller: TweenController = $TweenController
@onready var audio_controller: AudioController = $AudioController
@onready var mouse_area: Area2D = $MouseArea
var unit_name : String
var attack_speed : float = 0.55
var map: Map
var celebrating : bool = false

var is_alive : bool = true
func _ready() -> void:
	mouse_area.input_event.connect(_on_input_event)
	tween_controller.original_sprite_scale = Vector2(0.25, 0.25)
	$AttackTimer.wait_time = attack_speed

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MASK_LEFT:
			if held and event.pressed == false:
				global_position += Vector2(randf(), randf())
			held = event.pressed
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT == 0:
			if held:
				global_position += Vector2(randf(), randf())
			held = false

func in_unsafe_place() -> bool:
	if map == null:
		print("Nah")
		return false
	var tile_map: TileMapLayer = map.active_tile_map as TileMapLayer
	if tile_map == null:
		return false
	var pos = tile_map.local_to_map(tile_map.to_local(global_position))
	return tile_map.get_cell_tile_data(pos).get_collision_polygons_count(0) > 0

func _process(delta: float) -> void:
	if map.state == map.State.POSTGAME:
		if len(GameManager.get_units(Enemy)) == 0:
			if not celebrating:
				celebrating = true
				tween_controller.celebrate()
				audio_controller.play_random_sound_of_type("celebrate", unit_name)
		elif is_alive:
			is_alive = false
			$CollisionShape2D.disabled = true
			tween_controller.die()
			audio_controller.play_random_sound_of_type("death", unit_name)
			await tween_controller.unit_tween.finished
			#queue_free()
	if map.state != map.State.PREGAME:
		return
	z_index = position.y # sets the position so units are positons infront eachother forstaar du
	if (held or in_unsafe_place()) and get_parent().state == 0:
		audio_controller.play_random_sound_of_type("interact", unit_name)
		var pos = get_global_mouse_position()
		var width = sprite.texture.get_width()/2 * sprite.scale.x
		var height = sprite.texture.get_height()/2 * sprite.scale.y
		var corners = Utils.get_sprite_corners(map.border)
		pos.x = clamp(pos.x, corners[0].x + width, corners[1].x - width)
		pos.y = clamp(pos.y, corners[0].y + height, corners[2].y - height)
		global_position = pos
	if in_unsafe_place():
		sprite.modulate = Color(1, 0, 0)
	else:
		sprite.modulate = Color(1, 1, 1)
		
