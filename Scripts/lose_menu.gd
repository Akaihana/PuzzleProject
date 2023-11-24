extends ColorRect

@onready var grid: Node2D = $"../../Grid"
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	grid.game_over.connect(show_lose_menu)


func show_lose_menu() -> void:
	retry_button.grab_focus()
	get_tree().paused = true
	Shared.is_paused = true
	show()


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	Shared.is_paused = false
	hide()
	grid.retry()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Shared.is_paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
