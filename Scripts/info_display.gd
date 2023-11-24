extends Panel
class_name InfoDisplay

@onready var left_gem: TextureRect = %LeftGem
@onready var right_gem: TextureRect = %RightGem
@onready var mode_display: Label = %ModeDisplay
@onready var level_display: Label = %LevelDisplay

@onready var red_count: Label = %RedCount
@onready var green_count: Label = %GreenCount
@onready var blue_count: Label = %BlueCount
@onready var yellow_count: Label = %YellowCount


func _ready() -> void:
	if Shared.current_game_mode as Shared.Game_modes == Shared.Game_modes.CLASSIC:
		mode_display.text = "Mode:\nClassic"
		level_display.text = "Level: 1" 
	else:
		mode_display.text = "Mode:\nOutbreak"
		level_display.text = "Wave: 1" 


func update_next_gem(gem_colors: Array) -> void:
	left_gem.texture = Shared.data[gem_colors[0] as Shared.Gem_color].gem_texture
	right_gem.texture = Shared.data[gem_colors[1]  as Shared.Gem_color].gem_texture


func update_counts(values: Array) -> void:
	red_count.text = "%02d" % values[0]
	green_count.text = "%02d" % values[1]
	blue_count.text = "%02d" % values[2]
	yellow_count.text = "%02d" % values[3]

func update_level(value: int) -> void:
	if Shared.current_game_mode as Shared.Game_modes == Shared.Game_modes.CLASSIC:
		level_display.text = "Level: " + str(value)
	else:
		level_display.text = "Wave: " + str(value)
