class_name Player extends RigidBody2D

var held = false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	self.input_event.connect(_on_input_event)
	self.mouse_exited.connect(_on_mouse_exited)

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
		pos.x = clamp(pos.x, 0 + sprite.texture.get_width()/2, get_viewport_rect().size[0] * 0.4 - sprite.texture.get_width()/2)
		pos.y = clamp(pos.y, 0 + sprite.texture.get_height()/2, get_viewport_rect().size[1] - sprite.texture.get_height()/2)
		global_position = pos
