extends Panel
class_name InfoDisplay

@onready var left_gem: TextureRect = %LeftGem
@onready var right_gem: TextureRect = %RightGem
@onready var level_display: Label = %LevelDisplay

@onready var red_count: Label = %RedCount
@onready var green_count: Label = %GreenCount
@onready var blue_count: Label = %BlueCount
@onready var yellow_count: Label = %YellowCount


func update_next_gem(gem_colors: Array) -> void:
	left_gem.texture = Shared.data[gem_colors[0] as Shared.Gem_color].gem_texture
	right_gem.texture = Shared.data[gem_colors[1]  as Shared.Gem_color].gem_texture

func update_counts(values: Array) -> void:
	red_count.text = "%02d" % values[0]
	green_count.text = "%02d" % values[1]
	blue_count.text = "%02d" % values[2]
	yellow_count.text = "%02d" % values[3]

func update_level(value: int) -> void:
	level_display.text = "Level: " + str(value)
