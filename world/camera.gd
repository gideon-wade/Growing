extends Camera2D

@onready var camera_area_shape: CollisionShape2D = $CameraArea/CameraAreaShape

var speed = 5000
var zoom_speed = 0.03
var min_zoom = Vector2(0.02, 0.02)
var max_zoom = Vector2(0.7, 0.7)
var edge_threshold = 10
var current_zoom = Vector2(0.01, 0.01)

var fixed_toggle_point = Vector2(0,0)
var currently_moving_map = false

var rect : Rect2 

func _process(delta):
	rect = camera_area_shape.shape.get_rect()
	
	limit_left = rect.position[0] / 1.5
	limit_top = rect.position[1] / 1.5
	limit_right = rect.end[0]* 2.66
	limit_bottom = rect.end[1] * 3

	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_global_mouse_position() - global_position
	var scaled_edge_threshold = edge_threshold / zoom.x

	var movement = Vector2.ZERO

	var camera_view_half_width = viewport_size.x * 0.5 / zoom.x
	var camera_view_half_height = viewport_size.y * 0.5 / zoom.y
	
	if mouse_pos.x < -camera_view_half_width + scaled_edge_threshold:
		movement.x -= 1
	elif mouse_pos.x > camera_view_half_width - scaled_edge_threshold:
		movement.x += 1
	if mouse_pos.y < -camera_view_half_height + scaled_edge_threshold:
		movement.y -= 1
	elif mouse_pos.y > camera_view_half_height - scaled_edge_threshold:
		movement.y += 1
		
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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom -= Vector2(zoom_speed, zoom_speed)
			zoom = Vector2(max(min_zoom.x, zoom.x), max(min_zoom.y, zoom.y))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom += Vector2(zoom_speed, zoom_speed)
			zoom = Vector2(min(max_zoom.x, zoom.x), min(max_zoom.y, zoom.y))
		current_zoom = zoom
		
func move_map_around():
	var ref = get_viewport().get_mouse_position()
	self.global_position -= (ref - fixed_toggle_point) / current_zoom.x
	fixed_toggle_point = ref
