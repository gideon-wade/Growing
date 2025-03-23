extends Camera2D

var speed = 50
var zoom_speed = 0.03
var min_zoom = Vector2(0.45, 0.45)
var max_zoom = Vector2(0.85, 0.85)
var edge_threshold = 25
var current_zoom = Vector2(1, 1)

var fixed_toggle_point = Vector2(0,0)
var currently_moving_map = false
var frozen: bool = false

var rect : Rect2 

@onready var music: AudioStreamPlayer2D = $Music

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	position_smoothing_enabled = false

func _process(delta):
	if get_parent().info_shown:
		return
	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_global_mouse_position() - global_position
	var scaled_edge_threshold = edge_threshold / zoom.x

	var movement = Vector2.ZERO
		
	movement = movement.normalized() * speed
	position += movement * delta * (1 / (current_zoom.x))
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		# This happens once 'move_map' is pressed
		if( !currently_moving_map ):
			var ref = get_viewport().get_mouse_position()
			fixed_toggle_point = ref
			currently_moving_map = true
		# This happens while 'move_map' is pressed
		move_map_around()
	else:
		currently_moving_map = false

func _input(event):
	if get_parent().info_shown:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom -= Vector2(zoom_speed, zoom_speed)
			zoom = Vector2(max(min_zoom.x, zoom.x), max(min_zoom.y, zoom.y))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom += Vector2(zoom_speed, zoom_speed)
			zoom = Vector2(min(max_zoom.x, zoom.x), min(max_zoom.y, zoom.y))
		current_zoom = zoom
		
func move_map_around():
	if get_parent().info_shown or frozen:
		return
	position_smoothing_enabled = true
	var ref = get_viewport().get_mouse_position()
	self.global_position -= (ref - fixed_toggle_point) / current_zoom.x
	var clamp_x = (get_viewport().get_visible_rect().size[0] / 2) * (1 / current_zoom.x)
	var clamp_y = (get_viewport().get_visible_rect().size[1] / 2) * (1 / current_zoom.y)
	self.global_position.x = clamp(global_position.x, limit_left + clamp_x, limit_right - clamp_x)
	self.global_position.y = clamp(global_position.y, limit_top + clamp_y, limit_bottom - clamp_y)
	
	fixed_toggle_point = ref
