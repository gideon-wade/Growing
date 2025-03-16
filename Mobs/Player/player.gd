class_name Player extends RigidBody2D

var held = false
@onready var sprite: Sprite2D = $Sprite
@onready var tween_controller: TweenController = $TweenController
@onready var audio_controller: AudioController = $AudioController

var is_alive : bool = true
func _ready() -> void:
	self.input_event.connect(_on_input_event)
	self.mouse_exited.connect(_on_mouse_exited)
	tween_controller.original_sprite_scale = Vector2(0.25, 0.25)
	var unit_sounds = {
		"dead" : preload("res://sounds/dead.mp3")
	}
	audio_controller.set_unit_sounds(unit_sounds)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MASK_LEFT:
			held = event.pressed

func _on_mouse_exited() -> void:
	held = false

func _process(delta: float) -> void:
	if held and get_parent().state == 0:
		print("??? ", global_position)
		var pos = get_global_mouse_position()
		var width = sprite.texture.get_width()/2 * sprite.scale.x
		var height = sprite.texture.get_height()/2 * sprite.scale.y
		
		pos.x = clamp(pos.x, width, get_viewport_rect().size[0]  - width)
		pos.y = clamp(pos.y, height, get_viewport_rect().size[1] - height)
		global_position = pos
