class_name Gem
extends Node2D

var grid_r: int
var grid_c: int
var can_fall: bool
var matched: bool
var gem_color: Shared.Gem_color
var gem_position: Vector2
#use this variable to pair gems and check if the other has been destroyed for falling
var paired_gem: Gem

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	pass


func set_texture(texture: Texture2D) -> void:
	sprite_2d.texture = texture


func get_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size


func dim():
	sprite_2d.modulate = Color(1, 1, 1, 0.5)
