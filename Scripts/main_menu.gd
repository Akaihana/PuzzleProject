extends CenterContainer

@onready var arcade_mode_button: Button = %ArcadeModeButton


func _ready() -> void:
	arcade_mode_button.grab_focus()


func _on_arcade_mode_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	LevelTransition.fade_from_black()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

