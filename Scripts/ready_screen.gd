extends ColorRect

@onready var grid: Node2D = $"../../Grid"

func _ready() -> void:
	global_position = grid.global_position
