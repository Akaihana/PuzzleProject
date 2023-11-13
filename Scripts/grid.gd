class_name Grid
extends Node2D

const ROWS = 20
const COLUMNS = 10

signal gem_locked

@export var gem_container_scene: PackedScene

var grid_slot_radius: float = 27.0
var found_matches: bool
var grid: Array = []
var current_matches: Array = []

@onready var starting_position: Marker2D = $StartingPosition
@onready var bottom_right_boundary: Marker2D = $BottomRightBoundary
@onready var destroy_timer: Timer = $DestroyTimer
@onready var fall_timer: Timer = $FallTimer


func _ready() -> void:
	grid = make_2d_array()
	print_grid()


func spawn_gem_container() -> void:
	var gem_container = gem_container_scene.instantiate() as Gem_Container
	add_child(gem_container)
	gem_container.position = starting_position.position
	gem_container.other_gems = fill_gems_array()
	gem_container.lock_gem.connect(on_gem_locked)


func fill_gems_array() -> Array:
	var gems: Array = []
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null:
				gems.append(grid[r][c])
	return gems


func on_gem_locked(gem_container: Gem_Container) -> void:
	for gem in gem_container.gems:
		gem.gem_position = gem_container.global_position + gem.position
		var grid_position = position_to_grid(gem.gem_position)
		gem.grid_r = grid_position.x
		gem.grid_c = grid_position.y
		grid[gem.grid_r][gem.grid_c] = gem
		gem.reparent(self)
	gem_container.queue_free()
	print_grid()
	check_for_matches()


func position_to_grid(gem_position: Vector2) -> Vector2:
	var r = int((global_position.y + bottom_right_boundary.position.y - grid_slot_radius/2 - gem_position.y)/grid_slot_radius)
	var c = int(((gem_position.x - global_position.x - grid_slot_radius/2)/grid_slot_radius))
	return Vector2(r, c)


func grid_to_position(r: int, c:int) -> Vector2:
	var x_position = c * grid_slot_radius + global_position.x + grid_slot_radius/2
	var y_position = -(r * grid_slot_radius - global_position.y - bottom_right_boundary.position.y + grid_slot_radius/2)
	return Vector2(x_position, y_position)


func check_for_matches() -> void:
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null:
				var current_color = grid[r][c].gem_color
				if c < COLUMNS - 3:
					if grid[r][c + 1] != null and grid[r][c + 2] != null and grid[r][c + 3] != null:
						if grid[r][c + 1].gem_color == current_color and grid[r][c + 2].gem_color == current_color and grid[r][c + 3].gem_color == current_color:
							found_matches = true
							for i in range(4):
								match_and_dim(grid[r][c + i])
								current_matches.append(grid[r][c + i])
				if r < ROWS - 3:
					if grid[r + 1][c] != null and grid[r + 2][c] != null and grid[r + 3][c] != null:
						if grid[r + 1][c].gem_color == current_color and grid[r + 2][c].gem_color == current_color and grid[r + 3][c].gem_color == current_color:
							found_matches = true
							for i in range(4):
								match_and_dim(grid[r + i][c])
								current_matches.append(grid[r + i][c])
	if found_matches:
		destroy_timer.start()
	else:
		gem_locked.emit()


func match_and_dim(gem: Gem) -> void:
	gem.matched = true
	gem.dim()


func destroy_matched() -> void:
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null and grid[r][c].matched:
				if grid[r][c].paired_gem != null:
					var other_gem = grid[r][c].paired_gem
					other_gem.can_fall = true
					other_gem.set_texture(Shared.data[other_gem.gem_color].gem_texture_unpaired)
				grid[r][c].queue_free()
				grid[r][c] = null
	fall_timer.start()
	current_matches.clear()
	print_grid()


func make_gems_fall() -> void:
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null and grid[r][c].can_fall:
				var current_row = r
				while current_row > 0 and grid[current_row-1][c] == null:
					grid[current_row][c].move(grid_to_position(current_row - 1, c))
					grid[current_row][c].gem_position = grid_to_position(current_row - 1, c)
					grid[current_row - 1][c] = grid[current_row][c]
					grid[current_row][c] = null
					current_row -= 1
			if grid[r][c] != null and not grid[r][c].can_fall:
				var paired_gem = grid[r][c].paired_gem
				var current_row = r
				if c < COLUMNS - 1 and paired_gem == grid[r][c + 1]:
					while current_row > 0 and grid[current_row - 1][c] == null and grid[current_row - 1][c + 1] == null:
						grid[current_row][c].move(grid_to_position(current_row - 1, c))
						grid[current_row][c].gem_position = grid_to_position(current_row - 1, c)
						grid[current_row - 1][c] = grid[current_row][c]
						grid[current_row][c] = null
						grid[current_row][c + 1].move(grid_to_position(current_row - 1, c + 1))
						grid[current_row][c + 1].gem_position = grid_to_position(current_row - 1, c + 1)
						grid[current_row - 1][c + 1] = grid[current_row][c + 1]
						grid[current_row][c + 1] = null
						current_row -= 1
				elif r < ROWS - 1 and paired_gem == grid[r + 1][c]:
					while current_row > 0 and grid[current_row - 1][c] == null:
						grid[current_row][c].move(grid_to_position(current_row - 1, c))
						grid[current_row][c].gem_position = grid_to_position(current_row - 1, c)
						grid[current_row - 1][c] = grid[current_row][c]
						grid[current_row][c] = null
						grid[current_row + 1][c].move(grid_to_position(current_row, c))
						grid[current_row + 1][c].gem_position = grid_to_position(current_row, c)
						grid[current_row][c] = grid[current_row + 1][c]
						grid[current_row + 1][c] = null
						current_row -= 1
						
	found_matches = false
	check_for_matches()
	print_grid()
	print("finished falling")


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
			if grid[r][c] != null and grid[r][c].can_fall:
				line += "F"
			elif(grid[r][c] != null and grid[r][c].gem_color == Shared.Gem_color.RED):
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
	destroy_matched()


func _on_fall_timer_timeout() -> void:
	make_gems_fall()
