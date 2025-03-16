class_name AudioController extends AudioStreamPlayer2D

var _sounds : Dictionary = {}


func set_unit_sounds(sounds : Dictionary) -> void:
	_sounds = sounds

func play_unit_sound(sound : String) -> void:
	stream = _sounds[sound]
	play()

func play_ability_sound(ability_sound : AudioStream) -> void:
	stream = ability_sound
	play()
