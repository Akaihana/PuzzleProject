extends Node2D

@onready var grid: Node2D = $"../Grid"

func _ready() -> void:
	grid.spawn_gem_container()
	grid.gem_locked.connect(on_gem_locked)


func on_gem_locked() -> void:
	grid.spawn_gem_container()
