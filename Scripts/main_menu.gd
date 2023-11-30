extends CenterContainer

@onready var arcade_mode_button: Button = %ArcadeModeButton



func _ready() -> void:
	get_tree().get_root().set_disable_input(false)
	arcade_mode_button.grab_focus()


func _on_arcade_mode_button_pressed() -> void:
	Shared.current_game_mode = Shared.Game_modes.CLASSIC
	load_characte_select_scene()


func _on_outbreak_mode_button_pressed() -> void:
	Shared.current_game_mode = Shared.Game_modes.ENDLESS
	load_characte_select_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func load_characte_select_scene() -> void:
	get_tree().get_root().set_disable_input(true)
	get_tree().change_scene_to_file("res://Scenes/Menus/character_select.tscn")
	



