extends Node2D

@onready var grid: Node2D = $"../Grid"

func _ready() -> void:
	grid.spawn_gem_container()
