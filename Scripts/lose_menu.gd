extends ColorRect

@onready var grid: Node2D = $"../../Grid"
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	grid.game_over.connect(show_lose_menu)


func show_lose_menu() -> void:
	retry_button.grab_focus()
	get_tree().paused = true
	show()


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	hide()
	grid.retry_level()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
