class_name Grid
extends Node2D

const ROWS = 20
const COLUMNS = 10

signal gem_locked
signal game_over
signal level_cleared

@export var gem_container_scene: PackedScene
@export var corrupted_gem_scene: PackedScene
@export var chain_text_scene: PackedScene
@export var current_level: int = 1
@export var corrupted_count: int
@export var endless_corrupted_count: int
@export var max_row_spawn: int
@export var max_col_spawn: int

var current_wave: int = 1
var current_chain: int = 1
var grid_slot_radius: float = 27.0
var found_matches: bool
var wave_cleared: bool
var grid: Array = []
var current_matches: Array = []
var next_gem_colors: Array = [0, 0]
var corrupted_count_keeper: Array[int] = [0, 0, 0, 0]

@onready var starting_position: Marker2D = $StartingPosition
@onready var bottom_right_boundary: Marker2D = $BottomRightBoundary
@onready var destroy_timer: Timer = $DestroyTimer
@onready var fall_timer: Timer = $FallTimer
@onready var fall_delay: Timer = $FallDelay
@onready var wave_delay: Timer = $WaveDelay
@onready var info_display: Panel = $InfoDisplay
@onready var ready_screen: ColorRect = $"../CanvasLayer/ReadyScreen"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer_component: Node2D = $"../TimerComponent"


func _ready() -> void:
	grid = make_2d_array()
	if Shared.current_game_mode as Shared.Game_modes == Shared.Game_modes.CLASSIC:
		info_display.update_level(current_level)
		start_level()
		if timer_component != null:
			timer_component.queue_free()
	else:
		info_display.update_level(current_wave)
		start_wave()
	get_tree().paused = true
	Shared.is_paused = true
	set_next_gem_colors()
	ready_screen.visible = true
	animation_player.play("ready")
	await animation_player.animation_finished
	get_tree().paused = false
	Shared.is_paused = false
	ready_screen.visible = false
	spawn_gem_container()
	if timer_component != null:
		timer_component.start_level_msec = Time.get_ticks_msec()


func set_next_gem_colors():
	next_gem_colors[0] = Shared.Gem_color.values().pick_random()
	next_gem_colors[1] = Shared.Gem_color.values().pick_random()
	info_display.update_next_gem(next_gem_colors)


func spawn_gem_container() -> void:
	var gem_container = gem_container_scene.instantiate() as GemContainer
	add_child(gem_container)
	gem_container.gem_data_one = Shared.data[next_gem_colors[0] as Shared.Gem_color]
	gem_container.gem_data_two = Shared.data[next_gem_colors[1] as Shared.Gem_color]
	gem_container.generate_gems()
	gem_container.position = starting_position.position
	gem_container.other_gems = fill_gems_array()
	gem_container.lock_gem.connect(on_gem_locked)
	set_next_gem_colors()


func start_level() -> void:
	for color in Shared.Gem_color:
		for i in range(corrupted_count + current_level):
			var current_color = Shared.Gem_color[color]
			corrupted_count_keeper[current_color] += 1
			var corrupted_gem_data = Shared.data_corrupted[current_color]
			var corrupted_gem = corrupted_gem_scene.instantiate() as CorruptedGem
			add_child(corrupted_gem)
			var random_r = randi_range(0, max_row_spawn)
			var random_c = randi_range(0, max_col_spawn)
			var loops = 0
			while grid[random_r][random_c] != null and loops < 100:
				random_r = randi_range(0, max_row_spawn)
				random_c = randi_range(0, max_col_spawn)
				loops += 1
			loops = 0
			while check_for_spawn_clears(current_color, random_r, random_c) and loops < 100:
				current_color = Shared.Gem_color.values().pick_random()
				corrupted_gem_data = Shared.data_corrupted[current_color]
				loops += 1
			corrupted_gem.global_position = grid_to_position(random_r, random_c)
			corrupted_gem.gem_position = grid_to_position(random_r, random_c)
			corrupted_gem.set_texture(corrupted_gem_data.corrupted_gem_texture)
			corrupted_gem.gem_color = corrupted_gem_data.corrupted_gem_type
			grid[random_r][random_c] = corrupted_gem
	info_display.update_counts(corrupted_count_keeper)


func start_wave() -> void:
	for i in range(endless_corrupted_count + current_wave):
		var current_color = Shared.Gem_color.values().pick_random()
		var corrupted_gem_data = Shared.data_corrupted[current_color]
		var corrupted_gem = corrupted_gem_scene.instantiate() as CorruptedGem
		add_child(corrupted_gem)
		var random_r = randi_range(0, max_row_spawn)
		var random_c = randi_range(0, max_col_spawn)
		var loops = 0
		while grid[random_r][random_c] != null and loops < 100:
			random_r = randi_range(0, max_row_spawn)
			random_c = randi_range(0, max_col_spawn)
			loops += 1
		loops = 0
		#TODO make an alternate check for flood fill spawn clears
		while check_for_spawn_clears(current_color, random_r, random_c) and loops < 100:
			current_color = Shared.Gem_color.values().pick_random()
			corrupted_gem_data = Shared.data_corrupted[current_color]
			loops += 1
		corrupted_count_keeper[current_color] += 1
		corrupted_gem.global_position = grid_to_position(random_r, random_c)
		corrupted_gem.gem_position = grid_to_position(random_r, random_c)
		corrupted_gem.set_texture(corrupted_gem_data.corrupted_gem_texture)
		corrupted_gem.gem_color = corrupted_gem_data.corrupted_gem_type
		grid[random_r][random_c] = corrupted_gem
	info_display.update_counts(corrupted_count_keeper)


func fill_gems_array() -> Array:
	var gems: Array = []
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null:
				gems.append(grid[r][c])
	return gems


func on_gem_locked(gem_container: GemContainer) -> void:
	for gem in gem_container.gems:
		gem.gem_position = gem_container.global_position + gem.position
		var grid_position = position_to_grid(gem.gem_position)
		gem.grid_r = grid_position.x
		gem.grid_c = grid_position.y
		if gem.grid_r >= 0 and gem.grid_r < ROWS and gem.grid_c >= 0 and gem.grid_c < COLUMNS:
			grid[gem.grid_r][gem.grid_c] = gem
			gem.reparent(self)
		else:
			gem.queue_free()
	gem_container.queue_free()
	if Shared.is_flood_fill_mode:
		check_for_matches_flood()
	else:
		check_for_matches()


func position_to_grid(gem_position: Vector2) -> Vector2:
	var r = int((global_position.y + bottom_right_boundary.position.y - grid_slot_radius/2 - gem_position.y)/grid_slot_radius)
	var c = int(((gem_position.x - global_position.x - grid_slot_radius/2)/grid_slot_radius))
	return Vector2(r, c)


func grid_to_position(r: int, c:int) -> Vector2:
	var x_position = c * grid_slot_radius + global_position.x + grid_slot_radius/2
	var y_position = -(r * grid_slot_radius - global_position.y - bottom_right_boundary.position.y + grid_slot_radius/2)
	return Vector2(x_position, y_position)


#region Regular Clear Code
func check_for_matches() -> void:
	var spawned_chain_text: bool = false
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null:
				var current_color = grid[r][c].gem_color
				if c < COLUMNS - 3:
					if grid[r][c + 1] != null and grid[r][c + 2] != null and grid[r][c + 3] != null:
						if grid[r][c + 1].gem_color == current_color and grid[r][c + 2].gem_color == current_color and grid[r][c + 3].gem_color == current_color:
							found_matches = true
							if current_chain > 1 and not spawned_chain_text:
								spawn_chain_text(grid_to_position(r, c))
								spawned_chain_text = true
							for i in range(4):
								match_and_dim(grid[r][c + i])
								current_matches.append(grid[r][c + i])
				if r < ROWS - 3:
					if grid[r + 1][c] != null and grid[r + 2][c] != null and grid[r + 3][c] != null:
						if grid[r + 1][c].gem_color == current_color and grid[r + 2][c].gem_color == current_color and grid[r + 3][c].gem_color == current_color:
							found_matches = true
							if current_chain > 1 and not spawned_chain_text:
								spawn_chain_text(grid_to_position(r, c))
								spawned_chain_text = true
							for i in range(4):
								match_and_dim(grid[r + i][c])
								current_matches.append(grid[r + i][c])
	determine_next_phase()

func check_for_spawn_clears(current_color: Shared.Gem_color, r: int, c: int) -> bool:
	#check if spawning the virus here would cause a 4 in a row at start
	current_color = current_color as Shared.Gem_color
	if c >= 3 and grid[r][c - 3] != null and grid[r][c - 2] != null and grid[r][c - 1] != null:
		if grid[r][c - 3].gem_color == current_color and grid[r][c - 2].gem_color == current_color and grid[r][c - 1].gem_color == current_color:
			return true
	if c >= 2  and c < COLUMNS - 1 and grid[r][c - 2] != null and grid[r][c - 1] != null and grid[r][c + 1] != null:
		if grid[r][c - 2].gem_color == current_color and grid[r][c - 1].gem_color == current_color and grid[r][c + 1].gem_color == current_color:
			return true
	if c >= 1 and c < COLUMNS - 2 and grid[r][c - 1] != null and grid[r][c + 1] != null and grid[r][c + 2] != null:
		if grid[r][c - 1].gem_color == current_color and grid[r][c + 1].gem_color == current_color and grid[r][c + 2].gem_color == current_color:
			return true
	if c < COLUMNS - 3 and grid[r][c + 1] != null and grid[r][c + 2] != null and grid[r][c + 3] != null: 
		if grid[r][c + 1].gem_color == current_color and grid[r][c + 2].gem_color == current_color and grid[r][c + 3].gem_color == current_color:
			return true
		
	#check if spawning the virus here would cause a 4 in a column at start
	if r >= 3 and grid[r - 3][c] != null and grid[r - 2][c] != null and grid[r - 1][c] != null:
		if grid[r - 3][c].gem_color == current_color and grid[r - 2][c].gem_color == current_color and grid[r - 1][c].gem_color == current_color:
			return true
	if r >= 2 and r < ROWS - 1 and grid[r - 2][c] != null and grid[r - 1][c] != null and grid[r + 1][c] != null: 
		if  grid[r - 2][c].gem_color == current_color and grid[r - 1][c].gem_color == current_color and grid[r + 1][c].gem_color == current_color:
			return true
	if r >= 1 and r < ROWS - 2  and grid[r - 1][c] != null and grid[r + 1][c] != null and grid[r + 2][c] != null: 
		if grid[r - 1][c].gem_color == current_color and grid[r + 1][c].gem_color == current_color and grid[r - + 2][c].gem_color == current_color:
			return true
	if r < ROWS - 3 and grid[r + 1][c] != null and grid[r + 2][c] != null and grid[r + 3][c] != null: 
		if grid[r + 1][c].gem_color == current_color and grid[r + 2][c].gem_color == current_color and grid[r + 3][c].gem_color == current_color:
			return true
	return false
#endregion


#region Flood Fill Code
func check_for_matches_flood() -> void:
	var spawned_chain_text: bool = false
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null and not grid[r][c].checked:
				var current_color = grid[r][c].gem_color
				var num_matched: int = flood_fill(r, c, current_color)
				if num_matched >= 4:
					if current_chain > 1 and not spawned_chain_text:
								spawn_chain_text(grid_to_position(r, c))
								spawned_chain_text = true
					found_matches = true
					flood_fill_match(r, c, current_color)
	reset_checked()
	determine_next_phase()


func flood_fill(r: int, c:int, color: Shared.Gem_color) -> int:
	if r >= 0 and r < ROWS and c >= 0 and c < COLUMNS:
		if grid[r][c] != null:
			if not grid[r][c].checked and grid[r][c].gem_color == color:
				grid[r][c].checked = true
				return 1 + flood_fill(r + 1, c, color) + flood_fill(r - 1, c, color) + flood_fill(r, c + 1, color) + flood_fill(r, c - 1, color)
	return 0


func flood_fill_match(r: int, c:int, color: Shared.Gem_color):
	if r >= 0 and r < ROWS and c >= 0 and c < COLUMNS:
		if grid[r][c] != null:
			if not grid[r][c].matched and grid[r][c].gem_color == color:
				match_and_dim(grid[r][c])
				flood_fill_match(r + 1, c, color)
				flood_fill_match(r - 1, c, color)
				flood_fill_match(r, c + 1, color)
				flood_fill_match(r, c - 1, color)


func reset_checked() -> void:
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null:
				grid[r][c].checked = false

#TODO: make a check for spawn clears for flood filling

#endregion


func determine_next_phase() -> void:
	if found_matches:
		SoundManager.play_chain(current_chain)
		current_chain += 1
		found_matches = false
		destroy_timer.start()
	else:
		current_chain = 1
		if check_for_lose():
			game_over.emit()
		else:
			if Shared.current_game_mode as Shared.Game_modes == Shared.Game_modes.CLASSIC:
				gem_locked.emit()
			else:
				if wave_cleared:
					spawn_next_wave()
				else:
					gem_locked.emit()


func spawn_chain_text(spawn_position: Vector2) -> void:
	var chain_text = chain_text_scene.instantiate() as ChainText
	add_child(chain_text)
	chain_text.global_position = spawn_position
	chain_text.set_text(current_chain)


func check_for_lose() -> bool:
	if grid[ROWS - 1][COLUMNS/2 - 1] != null or grid[ROWS - 1][COLUMNS/2] != null:
		return true
	return false


func spawn_next_wave():
	wave_cleared = false
	current_wave += 1
	info_display.update_level(current_wave)
	start_wave()
	wave_delay.start()


func match_and_dim(gem) -> void:
	gem.matched = true
	gem.dim()


func destroy_matched() -> void:
	SoundManager.play_sound("gem_clear")
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null and grid[r][c].matched:
				if grid[r][c] is Gem and grid[r][c].paired_gem != null:
					var other_gem = grid[r][c].paired_gem
					other_gem.can_fall = true
					other_gem.set_texture(Shared.data[other_gem.gem_color].gem_texture_unpaired)
				elif grid[r][c] is CorruptedGem:
					corrupted_count_keeper[grid[r][c].gem_color] -= 1
				grid[r][c].queue_free()
				grid[r][c] = null
	info_display.update_counts(corrupted_count_keeper)
	current_matches.clear()
	if check_level_clear():
		if Shared.current_game_mode as Shared.Game_modes == Shared.Game_modes.CLASSIC:
			level_cleared.emit()
		else:
			wave_cleared = true
			fall_timer.start()
	else:
		fall_timer.start()


func check_level_clear() -> bool:
	var cleared = true
	for count in corrupted_count_keeper:
		if count != 0:
			cleared = false
	return cleared


func next_level() -> void:
	current_level += 1
	clear_grid()
	reset_corrupted_gem_count_keeper()
	_ready()


func make_gems_fall() -> void:
	var falling_gems: bool = false
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null and grid[r][c] is Gem and grid[r][c].can_fall:
				var current_row = r
				if current_row > 0 and grid[current_row-1][c] == null:
					falling_gems = true
					grid[current_row][c].move(grid_to_position(current_row - 1, c))
					grid[current_row][c].gem_position = grid_to_position(current_row - 1, c)
					grid[current_row - 1][c] = grid[current_row][c]
					grid[current_row][c] = null
					current_row -= 1
			if grid[r][c] != null and grid[r][c] is Gem and not grid[r][c].can_fall:
				var paired_gem = grid[r][c].paired_gem
				var current_row = r
				if c < COLUMNS - 1 and paired_gem == grid[r][c + 1]:
					if current_row > 0 and grid[current_row - 1][c] == null and grid[current_row - 1][c + 1] == null:
						falling_gems = true
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
					if current_row > 0 and grid[current_row - 1][c] == null:
						falling_gems = true
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
	SoundManager.play_sound("move")
	if falling_gems:
		fall_delay.start()
	else:
		SoundManager.play_sound("lock")
		if Shared.is_flood_fill_mode:
			check_for_matches_flood()
		else:
			check_for_matches()


func retry() -> void:
	clear_grid()
	reset_corrupted_gem_count_keeper()
	if Shared.current_game_mode as Shared.Game_modes == Shared.Game_modes.CLASSIC:
		_ready()
	else:
		current_wave = 1
		_ready()


func reset_corrupted_gem_count_keeper():
	corrupted_count_keeper = [0, 0, 0, 0]


func clear_grid() -> void:
	for r in ROWS:
		for c in COLUMNS:
			if grid[r][c] != null:
				grid[r][c].queue_free()
				grid[r][c] = null


func make_2d_array() -> Array:
	var array = []
	for row in ROWS:
		array.append([])
		for col in COLUMNS:
			array[row].append(null)
	return array


#region Timers
func _on_destroy_timer_timeout() -> void:
	destroy_matched()


func _on_fall_timer_timeout() -> void:
	make_gems_fall()


func _on_fall_delay_timeout() -> void:
	make_gems_fall()


func _on_wave_delay_timeout() -> void:
	gem_locked.emit()
#endregion


#region Debug Code
func print_grid() -> void:
	var debug_grid_display:Array[String] = []
	for r in grid.size():
		var line: String = str(r) + "\t"
		for c in grid[r].size():
			if grid[r][c] is CorruptedGem:
				line += "C"
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
	print()


func test_spawn() -> void:
	corrupted_count_keeper[Shared.Gem_color.RED] += 1
	var corrupted_gem_data = Shared.data_corrupted[Shared.Gem_color.RED]
	var corrupted_gem = corrupted_gem_scene.instantiate() as CorruptedGem
	add_child(corrupted_gem)
	var random_r = 4
	var random_c = 4
	corrupted_gem.global_position = grid_to_position(random_r, random_c)
	corrupted_gem.gem_position = grid_to_position(random_r, random_c)
	corrupted_gem.set_texture(corrupted_gem_data.corrupted_gem_texture)
	corrupted_gem.gem_color = corrupted_gem_data.corrupted_gem_type
	grid[random_r][random_c] = corrupted_gem
#endregion


