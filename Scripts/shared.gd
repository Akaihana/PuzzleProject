extends Node

enum Gem_color { RED, GREEN, BLUE, YELLOW }

var data: Dictionary = {
	Gem_color.RED: preload("res://Resources/gem_red_data.tres"),
	Gem_color.GREEN: preload("res://Resources/gem_green_data.tres"),
	Gem_color.BLUE: preload("res://Resources/gem_blue_data.tres"),
	Gem_color.YELLOW: preload("res://Resources/gem_yellow_data.tres")
}
