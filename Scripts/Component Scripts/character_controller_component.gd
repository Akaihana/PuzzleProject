class_name CharacterControllerComponent
extends Node

@export var actor: Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ability1"):
		actor.ability_one()
	if Input.is_action_just_pressed("ability2"):
		actor.ability_two()
