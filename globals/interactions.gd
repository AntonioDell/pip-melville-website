extends Node

@export var main_scene: PackedScene

func _input(event):
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE:
		if get_tree().current_scene.name != main_scene.get_state().get_node_name(0):
			Transition.fade_to(main_scene)
