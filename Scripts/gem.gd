class_name Gem
extends Node2D

var can_fall: bool

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	pass

func set_texture(texture: Texture2D) -> void:
	sprite_2d.texture = texture

func get_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size
