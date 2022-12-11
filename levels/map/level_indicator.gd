@tool
class_name LevelIndicator
extends CharacterBody2D

signal clicked(level_indicator)

@export var scene_to_load: PackedScene
@export var map_position: int = -1
@export var is_click_disabled := true:
	set(value):
		is_click_disabled = value
		$CollisionShape2D.disabled = is_click_disabled


func _ready():
	if map_position == -1:
		var count = get_tree().get_nodes_in_group("level_indicators").size()
		map_position = count-1


func _on_LevelIndicator_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", self)
