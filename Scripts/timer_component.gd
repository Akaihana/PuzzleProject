class_name TimerComponent
extends Node2D

var life_time: float = 300000.0
var start_level_msec: float = 0.0

@onready var info_display: Panel = $"../Grid/InfoDisplay"

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	info_display.update_timer(life_time - (Time.get_ticks_msec() - start_level_msec))
