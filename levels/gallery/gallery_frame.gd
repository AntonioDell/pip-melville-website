class_name GalleryFrame
extends Node2D

export(Texture) var image_texture: Texture setget set_image_texture

func set_image_texture(value: Texture):
	image_texture = value
	$Image.texture = image_texture
