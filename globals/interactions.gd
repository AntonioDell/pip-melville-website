extends Node

export(PackedScene) var main_scene: PackedScene

func _input(event):
	if event is InputEventKey and (event as InputEventKey).scancode == KEY_ESCAPE:
		if get_tree().current_scene.name != main_scene.get_state().get_node_name(0):
			$"/root/Transition".fade_to(main_scene)
