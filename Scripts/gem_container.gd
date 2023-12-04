class_name GemContainer
extends Node2D

signal lock_gem(gem_container: GemContainer)

var bounds = {
	"min_x": 0,
	"max_x": 270,
	"max_y": 540
}

var rotation_index: int = 0
var grid_offset_x: float
var grid_offset_y: float
var is_next_gem: bool
var is_holding_left: bool
var is_holding_right: bool
var wall_kicks: Array[Vector2]
var cells: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0)]
var gems: Array[Gem]
var other_gems: Array
var gem_data_one: Resource
var gem_data_two: Resource


@onready var move_down_timer: Timer = $MoveDownTimer
@onready var hold_down_timer: Timer = $HoldDownTimer
@onready var hold_left_timer: Timer = $HoldLeftTimer
@onready var hold_right_timer: Timer = $HoldRightTimer
@onready var hold_left_delay: Timer = $HoldLeftDelay
@onready var hold_right_delay: Timer = $HoldRightDelay
@onready var hold_down_delay: Timer = $HoldDownDelay
@onready var grace_timer: Timer = $GraceTimer

@onready var gem_scene = preload("res://Scenes/gem.tscn")

func _ready() -> void:
	grid_offset_x = global_position.x
	grid_offset_y = global_position.y
	wall_kicks = Shared.wall_kicks


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
		if hold_left_delay.is_stopped():
			hold_left_delay.start()
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
		if hold_right_delay.is_stopped():
			hold_right_delay.start()
		
	if Input.is_action_pressed("left"):
		hold_left_pressed()
	elif Input.is_action_pressed("right"):
		hold_right_pressed()
		
	if Input.is_action_just_released("left"):
		hold_left_delay.stop()
		hold_left_timer.stop()
	if Input.is_action_just_released("right"):
		hold_right_delay.stop()
		hold_right_timer.stop()
		
	if Input.is_action_just_pressed("down"):
		tap_down()
		if hold_down_delay.is_stopped():
			hold_down_delay.start()
	if Input.is_action_pressed("down"):
		hold_down_pressed()
	elif Input.is_action_just_released("down"):
		hold_down_timer.stop()
		move_down_timer.start()
		
	if Input.is_action_just_pressed("rotate_right"):
		rotate_gems(-1)
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_gems(1)
	
	
func generate_gems():
	var gem_one = gem_scene.instantiate() as Gem
	gems.append(gem_one)
	add_child(gem_one)
	gem_one.gem_color = gem_data_one.gem_type
	gem_one.set_texture(gem_data_one.gem_texture)
	var gem_two = gem_scene.instantiate() as Gem
	gems.append(gem_two)
	add_child(gem_two)
	gem_two.gem_color = gem_data_two.gem_type
	gem_two.set_texture(gem_data_two.gem_texture)
	gem_two.position = Vector2.RIGHT * gem_two.get_size()
	gem_one.paired_gem = gem_two
	gem_two.paired_gem = gem_one


func move(direction: Vector2) -> bool:
	var new_position = calculate_global_position(direction, global_position)
	if new_position != Vector2.ZERO:
		global_position = new_position
		return true
	return false


func tap_down():
	if move(Vector2.DOWN):
		move_down_timer.stop()
		move_down_timer.start()


func hold_down_pressed():
	if hold_down_delay.is_stopped() and hold_down_timer.is_stopped():
		hold_down_timer.start()
		move_down_timer.stop()


func hold_left_pressed():
	hold_right_timer.stop()
	if hold_left_delay.is_stopped() and hold_left_timer.is_stopped():
		hold_left_timer.start()


func hold_right_pressed():
	hold_left_timer.stop()
	if hold_right_delay.is_stopped() and hold_right_timer.is_stopped():
		hold_right_timer.start()


func calculate_global_position(direction: Vector2, starting_global_position: Vector2) -> Vector2:
	if is_colliding_with_other_gems(direction, starting_global_position):
		return Vector2.ZERO
	if not is_within_game_bounds(direction, starting_global_position):
		return Vector2.ZERO
	return starting_global_position + direction * Shared.gem_size


func is_colliding_with_other_gems(direction: Vector2, starting_global_position: Vector2) -> bool:
	for other_gem in other_gems:
		for gem in gems:
			if starting_global_position + gem.position + direction * gem.get_size().x == other_gem.gem_position:
				return true
	return false


func is_within_game_bounds(direction: Vector2, starting_global_position: Vector2) -> bool:
	for gem in gems:
		var new_position = gem.position + starting_global_position + direction * gem.get_size()
		if new_position.y >= bounds.get("max_y") + grid_offset_y:
			return false
		if new_position.x < bounds.get("min_x") + grid_offset_x || new_position.x > bounds.get("max_x") + grid_offset_x:
			return false
	return true


func rotate_gems(direction: int) -> void:
	var original_rotation_index = rotation_index
	apply_rotation(direction)
	rotation_index = wrap(rotation_index + direction, 0, 4)
	if not test_wall_kicks(rotation_index, direction):
		rotation_index = original_rotation_index
		apply_rotation(-direction)


func test_wall_kicks(rotation_index: int, rotation_direction: int) -> bool:
	for i in wall_kicks.size():
		var translation = wall_kicks[i]
		if move(translation):
			return true
	return false


func apply_rotation(direction: int) -> void:
	var rotation_matrix = Shared.clockwise_rotation_matrix if direction == 1 else Shared.counter_clockwise_rotation_matrix
	for i in cells.size():
		var cell = cells[i]
		var coordinates = rotation_matrix[0] * cell.x + rotation_matrix[1] * cell.y
		cells[i] = coordinates
	for i in gems.size():
		var gem = gems[i]
		gem.position = cells[i] * gem.get_size()


func lock():
	move_down_timer.stop()
	hold_down_timer.stop()
	hold_left_timer.stop()
	hold_right_timer.stop()
	lock_gem.emit(self)
	set_process_input(false)


func _on_timer_timeout() -> void:
	if not move(Vector2.DOWN):
		if grace_timer.is_stopped():
			grace_timer.start()
	else:
		grace_timer.stop()


func _on_hold_down_timer_timeout() -> void:
	if not move(Vector2.DOWN):
		if grace_timer.is_stopped():
			grace_timer.start()
	else:
		grace_timer.stop()


func _on_hold_left_timer_timeout() -> void:
	move(Vector2.LEFT)


func _on_hold_right_timer_timeout() -> void:
	move(Vector2.RIGHT)


func _on_grace_timer_timeout() -> void:
	if not move(Vector2.DOWN):
		lock()



