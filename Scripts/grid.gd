class_name Grid
extends Node2D

const ROWS = 20
const COLUMNS = 10

signal gem_locked

@export var gem_container_scene: PackedScene

var grid: Array = []
var gems: Array[Gem] = []

@onready var starting_position: Marker2D = $StartingPosition

func _ready() -> void:
	grid = make_2d_array()
	print_grid()


func spawn_gem_container() -> void:
	var gem_container = gem_container_scene.instantiate() as Gem_Container
	add_child(gem_container)
	gem_container.position = starting_position.position
	gem_container.other_gems = gems
	gem_container.lock_gem.connect(on_gem_locked)


func on_gem_locked(gem_container: Gem_Container) -> void:
	#append either the gems or the gem_contrainer to an array to hold within the grid
	#maybe only append gems to the appropriate slot in the 2D grid for use
	#TODO make a position to grid function to keep the color data within the grid
	for gem in gem_container.gems:
		gem.gem_position = gem_container.global_position + gem.position
		gems.append(gem)
		gem.reparent(self)
	gem_container.queue_free()
	gem_locked.emit()


func on_lock_gem(gem_container: Gem_Container) -> void:
	print("testing signal")


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
