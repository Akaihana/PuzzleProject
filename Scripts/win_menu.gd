extends ColorRect

@onready var grid: Node2D = $"../../Grid"
@onready var next_level_button: Button = %NextLevelButton
@onready var main_menu_button: Button = %MainMenuButton

func _ready() -> void:
	grid.level_cleared.connect(show_win_menu)


func show_win_menu() -> void:
	next_level_button.grab_focus()
	get_tree().paused = true
	Shared.is_paused = true
	show()


func _on_next_level_button_pressed() -> void:
	get_tree().paused = false
	Shared.is_paused = false
	hide()
	grid.next_level()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Shared.is_paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


