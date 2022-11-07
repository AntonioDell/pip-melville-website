class_name GalleryFrame
extends Node2D


signal clicked


@export var image_texture: Texture2D:
	get: 
		return image_texture # TODOConverter40 Non existent get function 
	set(mod_value):
		image_texture = mod_value
		$FramedPicture.set_texture(image_texture)


func _on_GalleryFrame_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked")

func start_swinging(move_to_right: bool) -> void:
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop(true)
	if move_to_right:
		$AnimationPlayer.play("swing_to_right_movement")
	else:
		$AnimationPlayer.play("swing_to_left_movement")
