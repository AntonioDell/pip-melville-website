tool
class_name LevelIndicator
extends KinematicBody2D

signal clicked(level_indicator)

export(NodePath) var player_path_follow_node: NodePath
export(PackedScene) var scene_to_load: PackedScene
export(int) var map_position: int
export(String) var level_name := "" setget set_level_name

func set_level_name(value: String):
	level_name = value
	if $Label:
		$Label.text = level_name
		$Label.set_rotation(-rotation)

func _on_LevelIndicator_input_event(viewport, event, shape_idx):
	if Engine.editor_hint:
		return
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", self)
