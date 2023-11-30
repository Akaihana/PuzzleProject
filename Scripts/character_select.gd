extends CanvasLayer

@onready var character_button_1: Button = %CharacterButton1

func _ready() -> void:
	get_tree().get_root().set_disable_input(false)
	character_button_1.grab_focus()


func load_main_scene() -> void:
	get_tree().get_root().set_disable_input(true)
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	LevelTransition.fade_from_black()


func _on_character_button_1_pressed() -> void:
	Shared.current_character = Shared.Characters.IRYS
	load_main_scene()


func _on_character_button_2_pressed() -> void:
	Shared.current_character = Shared.Characters.FAUNA
	load_main_scene()


func _on_character_button_3_pressed() -> void:
	Shared.current_character = Shared.Characters.KRONII
	load_main_scene()


func _on_character_button_4_pressed() -> void:
	Shared.current_character = Shared.Characters.MUMEI
	load_main_scene()


func _on_character_button_5_pressed() -> void:
	Shared.current_character = Shared.Characters.BAELZ
	load_main_scene()


func _on_back_button_pressed() -> void:
	get_tree().get_root().set_disable_input(true)
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


