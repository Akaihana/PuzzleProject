extends CanvasLayer

@onready var menu: Control = %Menu
@onready var settings_menu: Control = %SettingsMenu

@onready var arcade_mode_button: Button = %ArcadeModeButton


func _ready() -> void:
	get_tree().get_root().set_disable_input(false)
	arcade_mode_button.grab_focus()
	SoundManager.play_background_music("menu_music")


func _on_arcade_mode_button_pressed() -> void:
	Shared.current_game_mode = Shared.Game_modes.CLASSIC
	load_characte_select_scene()


func _on_outbreak_mode_button_pressed() -> void:
	Shared.current_game_mode = Shared.Game_modes.ENDLESS
	load_characte_select_scene()


func load_characte_select_scene() -> void:
	get_tree().get_root().set_disable_input(true)
	get_tree().change_scene_to_file("res://Scenes/Menus/character_select.tscn")


func _on_settings_button_pressed() -> void:
	menu.hide()
	settings_menu.show()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_menu_visibility_changed() -> void:
	if get_node("Menu").visible:
		if arcade_mode_button != null:
			arcade_mode_button.grab_focus()
