class_name Gem_Container
extends Node2D

var cells: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0)]
var gem_data_one: Resource
var gem_data_two: Resource

var is_next_gem: bool
var gems: Array[Gem]

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

	position = gem_data_one.spawn_position


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)


func move(direction: Vector2) -> bool:
	var new_position = calculate_global_position(direction, global_position)
	if new_position:
		global_position = new_position
		return true
	return false


func calculate_global_position(direction: Vector2, starting_global_position: Vector2):
	#TODO check if colliding with other gems/virus
	#TODOO check if within game bounds
	return starting_global_position + direction * gems[0].get_size().x
