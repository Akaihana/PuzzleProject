extends CanvasLayer

@onready var resume_button: Button = %ResumeButton
@onready var main_menu_button: Button = %MainMenuButton

@onready var pause_menu_container: CenterContainer = $PauseMenuBackground/PauseMenuContainer
@onready var settings_menu: Control = %SettingsMenu

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if not Shared.is_paused:
			get_tree().paused = true
			Shared.is_paused = true
			show()
			resume_button.grab_focus()
		else:
			get_tree().paused = false
			Shared.is_paused = false
			hide()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	Shared.is_paused = false
	hide()


func _on_settings_pressed() -> void:
	pause_menu_container.hide()
	settings_menu.show()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Shared.is_paused = false
	SoundManager.stop_all_sounds()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_pause_menu_container_visibility_changed() -> void:
	if get_node("PauseMenuBackground/PauseMenuContainer").visible:
		if resume_button != null:
			resume_button.grab_focus()
