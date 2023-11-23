extends CenterContainer

@onready var arcade_mode_button: Button = %ArcadeModeButton


func _ready() -> void:
	arcade_mode_button.grab_focus()


func _on_arcade_mode_button_pressed() -> void:
	Shared.current_game_mode = Shared.Game_modes.CLASSIC
	load_main_scene()


func _on_outbreak_mode_button_pressed() -> void:
	Shared.current_game_mode = Shared.Game_modes.ENDLESS
	load_main_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func load_main_scene() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	LevelTransition.fade_from_black()


