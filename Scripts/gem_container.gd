class_name Gem_Container
extends Node2D

@export var grid_offset_x: int
@export var grid_offset_y: int

var bounds = {
	"min_x": 0,
	"max_x": 270,
	"max_y": 540
}

var rotation_index: int
var is_next_gem: bool
var cells: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0)]
var gems: Array[Gem]
var gem_data_one: Resource
var gem_data_two: Resource

@onready var gem_scene = preload("res://Scenes/gem.tscn")

func _ready() -> void:
	generate_gems()


func generate_gems():
	var gem_color_one = Shared.Gem_color.values().pick_random()
	gem_data_one = Shared.data[gem_color_one]
	var gem_one = gem_scene.instantiate() as Gem
	gems.append(gem_one)
	add_child(gem_one)
	gem_one.set_texture(gem_data_one.gem_texture)
	
	var gem_color_two = Shared.Gem_color.values().pick_random()
	gem_data_two = Shared.data[gem_color_two]
	var gem_two = gem_scene.instantiate() as Gem
	gems.append(gem_two)
	add_child(gem_two)
	gem_two.set_texture(gem_data_two.gem_texture)
	gem_two.position = Vector2.RIGHT * gem_two.get_size()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_gems(1)
	#TODO left rotation
	#check rotation directions and add tweens to movements
	
func move(direction: Vector2) -> bool:
	var new_position = calculate_global_position(direction, global_position)
	if new_position != Vector2.ZERO:
		global_position = new_position
		return true
	return false


func calculate_global_position(direction: Vector2, starting_global_position: Vector2) -> Vector2:
	#TODO check if colliding with other gems/virus
	if not is_within_game_bounds(direction, starting_global_position):
		return Vector2.ZERO
	return starting_global_position + direction * gems[0].get_size().x


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


func apply_rotation(direction: int) -> void:
	var rotation_matrix = Shared.clockwise_rotation_matrix if direction == 1 else Shared.counter_clockwise_rotation_matrix
	for i in cells.size():
		var cell = cells[i]
		var coordinates = rotation_matrix[0] * cell.x + rotation_matrix[1] * cell.y
		cells[i] = coordinates
	for i in gems.size():
		var gem = gems[i]
		gem.position = cells[i] * gem.get_size()
