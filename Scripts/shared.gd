extends Node

enum Gem_color { RED, GREEN, BLUE, YELLOW }
enum Game_modes { CLASSIC, ENDLESS }
enum Characters { IRYS, FAUNA, KRONII, MUMEI, BAELZ }

var current_game_mode: Game_modes = Game_modes.CLASSIC
var current_character: Characters = Characters.IRYS
var gem_size: int = 27
var is_paused: bool = false
var wall_kicks: Array[Vector2] = [Vector2(0,0), Vector2(-1,0), Vector2(1,0), Vector2(0, -1), Vector2(0, 1)]


var data: Dictionary = {
	Gem_color.RED: preload("res://Resources/gem_red_data.tres"),
	Gem_color.GREEN: preload("res://Resources/gem_green_data.tres"),
	Gem_color.BLUE: preload("res://Resources/gem_blue_data.tres"),
	Gem_color.YELLOW: preload("res://Resources/gem_yellow_data.tres")
}

var data_corrupted: Dictionary = {
	Gem_color.RED: preload("res://Resources/corrupted_gem_red_data.tres"),
	Gem_color.GREEN: preload("res://Resources/corrupted_gem_green_data.tres"),
	Gem_color.BLUE: preload("res://Resources/corrupted_gem_blue_data.tres"),
	Gem_color.YELLOW: preload("res://Resources/corrupted_gem_yellow_data.tres")
}

var characters: Dictionary = {
	Characters.IRYS: preload("res://Scenes/Characters/character_irys.tscn"),
	Characters.FAUNA: preload("res://Scenes/Characters/character_fuana.tscn"),
	Characters.KRONII: preload("res://Scenes/Characters/character_kronii.tscn"),
	Characters.MUMEI: preload("res://Scenes/Characters/character_mumei.tscn"),
	Characters.BAELZ: preload("res://Scenes/Characters/character_baelz.tscn")
}

var clockwise_rotation_matrix: Array[Vector2] = [Vector2(0, -1), Vector2(1, 0)]
var counter_clockwise_rotation_matrix: Array[Vector2] = [Vector2(0, 1), Vector2(-1, 0)]
