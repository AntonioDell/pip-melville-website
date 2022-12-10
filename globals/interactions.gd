extends Node

@export var main_scene: PackedScene


func navigate_to_main_scene():
	if get_tree().current_scene.name != main_scene.get_state().get_node_name(0):
		Transition.fade_to(main_scene)


func _input(event):
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE:
		navigate_to_main_scene()

