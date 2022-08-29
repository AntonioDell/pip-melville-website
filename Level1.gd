extends Node

const MAX_IMAGE_COUNT := 3

var _image_names := PoolStringArray()
var _current_position := 0


onready var _data_repository := $"/root/DataRepository"
onready var _image_1 := $Images/Image1
onready var _image_2 := $Images/Image2
onready var _image_3 := $Images/Image3

func _ready():
	if _data_repository.is_data_info_loaded():
		_init_gallery()
	else:
		_data_repository.connect("data_info_loaded", self, "_init_gallery")

func _init_gallery():
	_image_names = _data_repository.get_image_names()
	_show_current_images()


func _show_current_images():
	if _current_position >= _image_names.size():
		_current_position = 0
	elif _current_position < 0:
		_current_position = _image_names.size() - _image_names.size() % MAX_IMAGE_COUNT
	
	for image_sprite in [_image_1, _image_2, _image_3]:
		image_sprite.visible = false
	var current_image_names = Array(_image_names).slice(_current_position, _current_position + (MAX_IMAGE_COUNT - 1))
	var visible_images := []
	# TODO: Make dependent on MAX_IMAGE_COUNT
	if current_image_names.size() == 3:
		visible_images = [_image_1, _image_2, _image_3]
	elif current_image_names.size() == 2:
		visible_images = [_image_1, _image_3]
	else:
		visible_images = [_image_2]
		
	for i in visible_images.size():
		var image_sprite := visible_images[i] as Sprite
		var image_name = current_image_names[i]
		var image = yield(_data_repository.get_image(image_name), "completed")
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		image_sprite.texture = texture
		image_sprite.visible = true


func _on_BtnNext_pressed():
	_current_position = _current_position + MAX_IMAGE_COUNT
	_show_current_images()


func _on_BtnPrevious_pressed():
	_current_position = _current_position - MAX_IMAGE_COUNT
	_show_current_images()
