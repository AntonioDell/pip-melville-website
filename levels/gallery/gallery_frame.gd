class_name GalleryFrame
extends Node2D


signal clicked


export(Texture) var image_texture: Texture setget set_image_texture

func set_image_texture(value: Texture):
	image_texture = value
	$Image.texture = image_texture


func _on_GalleryFrame_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked")
