class_name Gem
extends Node2D

@export var fall_time: float

var grid_r: int
var grid_c: int
var can_fall: bool
var matched: bool
var checked: bool
var gem_color: Shared.Gem_color
var gem_position: Vector2
var paired_gem: Gem

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	pass


func set_texture(texture: Texture2D) -> void:
	sprite_2d.texture = texture


func get_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size


func dim() -> void:
	sprite_2d.modulate = Color(1, 1, 1, 0.5)


func move(target: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", target, fall_time).set_trans(Tween.TRANS_ELASTIC)
