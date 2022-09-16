@tool
class_name LevelIndicator
extends CharacterBody2D

signal clicked(level_indicator)

@export var player_path_follow_node: NodePath
@export var scene_to_load: PackedScene
@export var map_position: int
@export var level_name := "":
	get:
		return level_name # TODOConverter40 Non existent get function 
	set(mod_value):
		level_name = mod_value
		if $Label:
			$Label.text = level_name
			$Label.set_rotation(-rotation)

func _on_LevelIndicator_input_event(viewport, event, shape_idx):
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", self)
