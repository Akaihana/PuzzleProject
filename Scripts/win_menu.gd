extends ColorRect

@onready var grid: Node2D = $"../../Grid"
@onready var next_level_button: Button = %NextLevelButton
@onready var main_menu_button: Button = %MainMenuButton

func _ready() -> void:
	grid.level_cleared.connect(show_win_menu)


func show_win_menu() -> void:
	next_level_button.grab_focus()
	get_tree().paused = true
	show()


func _on_next_level_button_pressed() -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


