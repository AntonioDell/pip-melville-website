class_name LevelIndicator
extends CharacterBody2D

signal clicked(level_indicator)

@export var scene_to_load: PackedScene
@export var map_position: int

func _on_LevelIndicator_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", self)
