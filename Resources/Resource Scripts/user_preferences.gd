class_name UserPreferences 
extends Resource

@export_range(0, 1, 0.05) var music_audio_level: float = 1.0
@export_range(0, 1, 0.05) var sfx_audio_level: float = 1.0
@export var flood_fill_mode_on: bool
@export var action_events: Dictionary = {}

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")


static func load_or_create() -> UserPreferences:
	var res: UserPreferences = load("user://user_prefs.tres") as UserPreferences
	if not res:
		res = UserPreferences.new()
	return res
