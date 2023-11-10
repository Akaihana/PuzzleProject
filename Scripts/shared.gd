extends Node

enum Gem_color { RED, GREEN, BLUE, YELLOW }

var wall_kicks: Array[Vector2] = [Vector2(0,0), Vector2(-1,0), Vector2(1,0), Vector2(0, -1), Vector2(0, 1)]

var data: Dictionary = {
	Gem_color.RED: preload("res://Resources/gem_red_data.tres"),
	Gem_color.GREEN: preload("res://Resources/gem_green_data.tres"),
	Gem_color.BLUE: preload("res://Resources/gem_blue_data.tres"),
	Gem_color.YELLOW: preload("res://Resources/gem_yellow_data.tres")
}

var clockwise_rotation_matrix: Array[Vector2] = [Vector2(0, -1), Vector2(1, 0)]
var counter_clockwise_rotation_matrix: Array[Vector2] = [Vector2(0, 1), Vector2(-1, 0)]
