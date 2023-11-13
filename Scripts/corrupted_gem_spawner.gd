class_name CorruptedGemSpawner
extends Node2D

@onready var grid: Node2D = $"../Grid"

func on_start_level() -> void:
	grid.start_level()
