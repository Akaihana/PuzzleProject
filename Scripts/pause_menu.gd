extends ColorRect

@onready var resume_button: Button = %ResumeButton
@onready var main_menu_button: Button = %MainMenuButton

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		show()
		resume_button.grab_focus()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
