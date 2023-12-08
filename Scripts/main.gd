extends Node2D

func _ready() -> void:
	SoundManager.play_background_music()
	get_tree().get_root().set_disable_input(false)
