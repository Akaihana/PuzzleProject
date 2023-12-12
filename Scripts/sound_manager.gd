extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sound_player: AudioStreamPlayer = $SoundPlayer

var menu_background_music = preload("res://Assets/Audio/Music/glitch-interstellar.mp3")
var game_background_music = preload("res://Assets/Audio/Music/fsm-team-escp-steps-on-clouds.mp3")

var move_sound = preload("res://Assets/Audio/Sounds/Move.wav")
var lock_sound = preload("res://Assets/Audio/Sounds/Lock.wav")
var rotate_sound = preload("res://Assets/Audio/Sounds/Rotate.wav")
var gem_clear = preload("res://Assets/Audio/Sounds/GemClear.wav")

var chains: Array = [
	preload("res://Assets/Audio/Sounds/Chain_1.wav"),
	preload("res://Assets/Audio/Sounds/Chain_2.wav"),
	preload("res://Assets/Audio/Sounds/Chain_3.wav"),
	preload("res://Assets/Audio/Sounds/Chain_4.wav")
]

func _ready() -> void:
	pass

func play_background_music(music_name: String) -> void:
	match music_name: 
		"menu_music": music_player.stream = menu_background_music
		"game_music": music_player.stream = game_background_music
	music_player.play()

func play_sound(sound_name: String) -> void:
	match sound_name:
		"move": sound_player.stream = move_sound
		"lock": sound_player.stream = lock_sound
		"rotate": sound_player.stream = rotate_sound
		"gem_clear": sound_player.stream = gem_clear
	sound_player.play()

func play_chain(chain_value: int) -> void:
	chain_value = clamp(chain_value, 0, chains.size() - 1)
	sound_player.stream = chains[chain_value]
	sound_player.play()


func stop_all_sounds():
	music_player.stop()
	sound_player.stop()
