class_name Utils extends Node


static func get_sprite_corners(x_sprite: Sprite2D) -> Array:
	var texture_size = x_sprite.texture.get_size()
		
	var half_width = texture_size.x / 2.0
	var half_height = texture_size.y / 2.0
		
	var top_left = Vector2(-half_width, -half_height)
	var top_right = Vector2(half_width, -half_height)
	var bottom_left = Vector2(-half_width, half_height)
	var bottom_right = Vector2(half_width, half_height)
	var x_transform = x_sprite.get_global_transform()
	top_left = x_transform * top_left
	top_right = x_transform * top_right
	bottom_left = x_transform * bottom_left
	bottom_right = x_transform * bottom_right
		
	return [top_left, top_right, bottom_left, bottom_right]
