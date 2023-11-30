extends ColorRect

@onready var resume_button: Button = %ResumeButton
@onready var main_menu_button: Button = %MainMenuButton

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and not Shared.is_paused:
		get_tree().paused = true
		Shared.is_paused = true
		show()
		resume_button.grab_focus()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	Shared.is_paused = false
	hide()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Shared.is_paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
