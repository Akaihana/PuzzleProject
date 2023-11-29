class_name ChainText
extends Node2D

@onready var label: Label = $Label

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

func set_text(current_chain: int) -> void:
	label.text = str(current_chain) + "x chain"
	
