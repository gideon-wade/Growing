extends Node2D
@export var noise_texture : NoiseTexture2D
var noise : Noise
var noises = []
var source_id = 0
@onready var tile_map: TileMapLayer = $TileMap
var tile_size = 128
#Water
var water_dark_atlas = Vector2i(3,2)
var water_semi_dark_atlas = Vector2i(2,2)
var water_semibright_atlas = Vector2i(1,2)
var water_bright_atlas = Vector2i(0,2)
#dirt/sand
var dirt_dark_atlas = Vector2i(0,1)
var dirt_semi_dark_atlas = Vector2i(1,1)
var dirt_semibright_atlas = Vector2i(2,1)
var dirt_bright_atlas = Vector2i(3,1)
#grass
var grass_dark_atlas = Vector2i(2,0)
var grass_semibright_atlas = Vector2i(1,0)
var grass_bright_atlas = Vector2i(0,0)

var first_tile 
var tiles = {}
var mobs_on_tiles = {}
const PEASANT = preload("res://art/units/peasant.png")

func _ready() -> void:
	noise = noise_texture.noise
	var rng = RandomNumberGenerator.new()
	noise.seed = rng.randi()
	place_tiles()
	place_mobs()

func place_tiles() -> void:
	for x in range(noise_texture.width):
		for y in range(noise_texture.height):
			noises.append(noise.get_noise_2d(x,y))
			var noise_val = float(noise.get_noise_2d(x,y))
			if noise_val < -0.43:
				tile_map.set_cell(Vector2(x,y), source_id, water_dark_atlas)
			elif noise_val < -0.34:
				tile_map.set_cell(Vector2(x,y), source_id, water_semi_dark_atlas)
			elif noise_val < -0.28:
				tile_map.set_cell(Vector2(x,y), source_id, water_semibright_atlas)
			elif noise_val < -0.14:
				tile_map.set_cell(Vector2(x,y), source_id, water_bright_atlas)
			elif noise_val < -0.06:
				tile_map.set_cell(Vector2(x,y), source_id, dirt_bright_atlas)
			elif noise_val < 0.04:
				tile_map.set_cell(Vector2(x,y), source_id, dirt_semibright_atlas)
			elif noise_val < 0.11:
				tile_map.set_cell(Vector2(x,y), source_id, dirt_semi_dark_atlas)
			elif noise_val < 0.16:
				tile_map.set_cell(Vector2(x,y), source_id, dirt_dark_atlas)
			elif noise_val < 0.22:
				tile_map.set_cell(Vector2(x,y), source_id, grass_bright_atlas)
			elif noise_val < 0.37:
				tile_map.set_cell(Vector2(x,y), source_id, grass_semibright_atlas)
			else:
				tile_map.set_cell(Vector2(x,y), source_id, grass_dark_atlas)
			var clicked_cell = Vector2i(x,y)
			var tile = tile_map.get_cell_tile_data(clicked_cell)
			if tile:
				tiles[clicked_cell] = tile
		GameManager.tiles = tiles
				
func place_mobs() -> void:
	for tile in tiles:
		var valid = true
		if tiles[tile].get_custom_data("Can Spawn"):
			for i in range(5):
				for j in range(5):
					if i == 0 and j == 0:
						continue
					if tiles.get(tile + Vector2i(i,j), null) and mobs_on_tiles.get(tile + Vector2i(i,j), false):
						valid = false
					if tiles.get(tile - Vector2i(i,j), null) and mobs_on_tiles.get(tile - Vector2i(i,j), false):
						valid = false
					if tiles.get(tile + Vector2i(-i,j), null) and mobs_on_tiles.get(tile + Vector2i(-i,j), false):
						valid = false
					if tiles.get(tile + Vector2i(i,-j), null) and mobs_on_tiles.get(tile + Vector2i(i,-j), false):
						valid = false
			if valid:
				print(mobs_on_tiles)
				spawn_mob(tile)

func spawn_mob(tile) -> void:
	print("spawning mob here ", tile)
	mobs_on_tiles[tile] = "Peasant"
	var sprite = Sprite2D.new()
	sprite.texture = PEASANT
	sprite.scale = Vector2(0.2, 0.2)
	self.add_child(sprite)
	sprite.position = tile * Vector2i(tile_size, 96) + Vector2i(tile_size / 2, tile_size / 3) + Vector2i(64 if (tile.y%2==1) else 0, 0)
	print("sprite.position ", sprite.position)
	
	
