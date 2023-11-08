class_name Grid
extends Node2D

const ROWS = 20
const COLUMNS = 10

@export var gem_container_scene: PackedScene

var grid: Array = []

@onready var starting_position: Marker2D = $StartingPosition

func _ready() -> void:
	grid = make_2d_array()
	print_grid()


func spawn_gem_container() -> void:
	var gem_container = gem_container_scene.instantiate() as Gem_Container
	add_child(gem_container)
	gem_container.position = starting_position.position


func make_2d_array() -> Array:
	var array = []
	for row in ROWS:
		array.append([])
		for col in COLUMNS:
			array[row].append(null)
	return array


func print_grid() -> void:
	var debug_grid_display:Array[String] = []
	for r in grid.size():
		var line: String = str(r) + "\t"
		for c in grid[r].size():
			if(grid[r][c]):
				line += grid[r][c]
			else:
				line += "-"
		debug_grid_display.append(line)
	
	for r in debug_grid_display.size():
		print(debug_grid_display[debug_grid_display.size() - 1 - r])
