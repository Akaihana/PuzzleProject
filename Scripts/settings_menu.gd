extends Control

@export var action_items: Array[String]
@export var previous_menu: Control

var in_settings: bool = false

@onready var flood_fill_mode_toggle: CheckButton = %FloodFillModeToggle
@onready var controller_settings_grid_container: GridContainer = %ControllerSettingsGridContainer
@onready var return_button: Button = %ReturnButton

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

var user_prefs: UserPreferences

func _ready() -> void:
	flood_fill_mode_toggle.button_pressed = Shared.is_flood_fill_mode
	user_prefs = UserPreferences.load_or_create()
	if flood_fill_mode_toggle:
		flood_fill_mode_toggle.button_pressed = user_prefs.flood_fill_mode_on
		Shared.is_flood_fill_mode = user_prefs.flood_fill_mode_on
	if music_slider:
		music_slider.value = user_prefs.music_audio_level
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_audio_level
	create_action_remap_items()


func create_action_remap_items() -> void:
	#var previous_item = controller_settings_grid_container.get_child(controller_settings_grid_container.get_child_count() - 1)

	for i in range(action_items.size()):
		var action = action_items[i]
		var label = Label.new()
		label.text = action
		controller_settings_grid_container.add_child(label)
		
		var button = RemapButton.new()
		button.action = action
		#print(previous_item)
		#print(previous_item.get_path())
		#button.focus_neighbor_top = previous_item.get_path()
		#previous_item.focus_neighbor_bottom = button.get_path()
		#if i == action_items.size() - 1:
			#return_button.focus_neighbor_top = button.get_path()
			#button.focus_neighbor_bottom = return_button.get_path()
		#previous_item = button
		
		if user_prefs:
			if user_prefs.action_events.has(action):
				var event = user_prefs.action_events[action]
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)
			button.action_remapped.connect(_on_action_remapped)
		controller_settings_grid_container.add_child(button)


func _on_action_remapped(action: String, event: InputEvent) -> void:
	if user_prefs:
		user_prefs.action_events[action] = event
		user_prefs.save()


func _on_visibility_changed() -> void:
	if self.visible:
		flood_fill_mode_toggle.grab_focus()
		in_settings = true
	else:
		in_settings = false


func _on_flood_fill_mode_toggle_toggled(toggled_on: bool) -> void:
	Shared.is_flood_fill_mode = toggled_on
	if user_prefs:
		user_prefs.flood_fill_mode_on = toggled_on
		user_prefs.save()


func _on_return_button_pressed() -> void:
	self.hide()
	previous_menu.show()


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.05)
	if user_prefs:
		user_prefs.music_audio_level = value
		user_prefs.save()


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.05)
	if in_settings:
		SoundManager.play_sound("gem_clear")
	if user_prefs:
		user_prefs.sfx_audio_level = value
		user_prefs.save()


