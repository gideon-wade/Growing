class_name AudioController extends AudioStreamPlayer2D

var _sounds : Dictionary = {}
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	_sounds["dead"] = preload("res://sounds/dead.mp3")

func set_unit_sounds(sounds : Dictionary) -> void:
	_sounds = sounds

func play_unit_sound(sound : String) -> void:
	stream = _sounds[sound]
	play()

func play_random_sound_of_type(sound_type : String, unit_name : String) -> void:
	var file_path = "res://sounds/" + unit_name.to_lower() + "/"
	file_path += unit_name.to_lower() + "_" + sound_type
	file_path += str(rng.randi_range(1, GameManager.UnitSounds[unit_name][sound_type])) + ".mp3"
	stream = load(file_path)
	set_pitch_scale(rng.randf_range(0.9, 1.1))
	play()

func play_ability_sound(ability_sound : AudioStream) -> void:
	stream = ability_sound
	play()
