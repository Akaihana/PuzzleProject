class_name Grid
extends Node2D

const ROWS = 20
const COLUMNS = 10

signal gem_locked

@export var gem_container_scene: PackedScene

var grid: Array = []
var gems: Array[Gem] = []
var grid_slot_radius = 27

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
	for gem in gem_container.gems:
		gem.gem_position = gem_container.global_position + gem.position
		print(gem.gem_position)
		var grid_position = position_to_grid(gem.gem_position)
		grid[grid_position.x][grid_position.y] = gem
		gems.append(gem)
		gem.reparent(self)
	gem_container.queue_free()
	print_grid()
	check_for_matches()
	gem_locked.emit()


func check_for_matches():
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null:
				var current_color = grid[r][c].gem_color
				if c < COLUMNS - 3:
					if grid[r][c + 1] != null and grid[r][c + 2] != null and grid[r][c + 3] != null:
						if grid[r][c + 1].gem_color == current_color and grid[r][c + 2].gem_color == current_color and grid[r][c + 3].gem_color == current_color:
							#TODO
							# delete the cells from the grid
							# queue free the gems from the board
							print("Found match row")
				if r < ROWS - 3:
					if grid[r + 1][c] != null and grid[r + 2][c] != null and grid[r + 3][c] != null:
						if grid[r + 1][c].gem_color == current_color and grid[r + 2][c].gem_color == current_color and grid[r + 3][c].gem_color == current_color:
							print("Found match column")

func position_to_grid(gem_position: Vector2):
	var r = int((590.5 - gem_position.y)/grid_slot_radius)
	var c = int(((gem_position.x - global_position.x + grid_slot_radius/2)/grid_slot_radius))
	return Vector2(r, c)


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
			if(grid[r][c] != null and grid[r][c].gem_color == Shared.Gem_color.RED):
				line += "R"
			elif(grid[r][c] != null and grid[r][c].gem_color == Shared.Gem_color.GREEN):
				line += "G"
			elif(grid[r][c] != null and grid[r][c].gem_color == Shared.Gem_color.BLUE):
				line += "B"
			elif(grid[r][c] != null and grid[r][c].gem_color == Shared.Gem_color.YELLOW):
				line += "Y"
			else:
				line += "-"
		debug_grid_display.append(line)
	
	for r in debug_grid_display.size():
		print(debug_grid_display[debug_grid_display.size() - 1 - r])
