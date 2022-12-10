extends Node2D



func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		Interactions.navigate_to_main_scene()
