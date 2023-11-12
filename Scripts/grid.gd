class_name Grid
extends Node2D

const ROWS = 20
const COLUMNS = 10

signal gem_locked

@export var gem_container_scene: PackedScene

var grid: Array = []
var gems: Array[Gem] = []
var current_matches: Array = []
var grid_slot_radius: float = 27.0
var found_matches: bool


@onready var starting_position: Marker2D = $StartingPosition
@onready var bottom_right_boundary: Marker2D = $BottomRightBoundary
@onready var destroy_timer: Timer = $DestroyTimer

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
		var grid_position = position_to_grid(gem.gem_position)
		gem.grid_r = grid_position.x
		gem.grid_c = grid_position.y
		grid[gem.grid_r][gem.grid_c] = gem
		gems.append(gem)
		gem.reparent(self)
	gem_container.queue_free()
	print_grid()
	check_for_matches()
	if not found_matches:
		gem_locked.emit()


func position_to_grid(gem_position: Vector2):
	var r = int((global_position.y + bottom_right_boundary.position.y - grid_slot_radius/2 - gem_position.y)/grid_slot_radius)
	var c = int(((gem_position.x - global_position.x - grid_slot_radius/2)/grid_slot_radius))
	return Vector2(r, c)


func check_for_matches():
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null:
				var current_color = grid[r][c].gem_color
				if c < COLUMNS - 3:
					if grid[r][c + 1] != null and grid[r][c + 2] != null and grid[r][c + 3] != null:
						if grid[r][c + 1].gem_color == current_color and grid[r][c + 2].gem_color == current_color and grid[r][c + 3].gem_color == current_color:
							#TODO
							found_matches = true
							for i in range(4):
								match_and_dim(grid[r][c + i])
								current_matches.append(grid[r][c + i])
							# delete the cells from the grid
							# queue free the gems from the board
							print("Found match row")
				if r < ROWS - 3:
					if grid[r + 1][c] != null and grid[r + 2][c] != null and grid[r + 3][c] != null:
						if grid[r + 1][c].gem_color == current_color and grid[r + 2][c].gem_color == current_color and grid[r + 3][c].gem_color == current_color:
							found_matches = true
							for i in range(4):
								match_and_dim(grid[r + i][c])
								current_matches.append(grid[r + i][c])
							print("Found match column")
	destroy_timer.start()


func match_and_dim(gem: Gem):
	gem.matched = true
	gem.dim()


func destroy_matches():
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null and grid[r][c].matched:
				grid[r][c].queue_free()
				grid[r][c] = null
	current_matches.clear()



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


func _on_destroy_timer_timeout() -> void:
	destroy_matches()
