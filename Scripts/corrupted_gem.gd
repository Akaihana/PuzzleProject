class_name CorruptedGem
extends Area2D

var grid_r: int
var grid_c: int
var matched: bool
var gem_color: Shared.Gem_color
var gem_position: Vector2

@onready var sprite_background: Sprite2D = $SpriteBackground
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	pass


func set_texture(texture: Texture2D) -> void:
	sprite_2d.texture = texture


func get_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size


func dim() -> void:
	sprite_background.modulate = Color(1, 1, 1, 0.5)
	sprite_2d.modulate = Color(1, 1, 1, 0.5)
	
