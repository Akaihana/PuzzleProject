class_name InfoDisplay
extends Panel

@onready var left_gem: TextureRect = %LeftGem
@onready var right_gem: TextureRect = %RightGem
@onready var mode_display: Label = %ModeDisplay
@onready var level_display: Label = %LevelDisplay

@onready var red_count: Label = %RedCount
@onready var green_count: Label = %GreenCount
@onready var blue_count: Label = %BlueCount
@onready var yellow_count: Label = %YellowCount

@onready var timer_panel: Panel = $TimerPanel
@onready var timer_display: Label = %TimerDisplay

func _ready() -> void:
	if Shared.current_game_mode as Shared.Game_modes == Shared.Game_modes.CLASSIC:
		mode_display.text = "Mode:\nClassic"
		level_display.text = "Level: 1" 
	else:
		mode_display.text = "Mode:\nOutbreak"
		level_display.text = "Wave: 1" 
		timer_panel.visible = true


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


func update_timer(value: float) -> void:
	timer_display.text = time_to_minutes_secs_mili(value)


func time_to_minutes_secs_mili(value: float) -> String:
	var time = value / 1000
	var mins = int(time) / 60
	time -= mins * 60
	var secs = int(time)
	var mili = int((time - int(time)) * 100)
	return "%02d" % mins + ":" + "%02d" % secs + ":" + "%02d" % mili

