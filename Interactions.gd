extends Node


func _input(event):
	if event is InputEventKey and (event as InputEventKey).scancode == KEY_ESCAPE:
		get_tree().change_scene("res://Main.tscn")
