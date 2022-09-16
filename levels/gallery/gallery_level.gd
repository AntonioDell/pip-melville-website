extends Node

const MAX_IMAGE_COUNT := 3

var _image_names := PackedStringArray()
var _current_position := 0

@onready var _image_1 := $Images/GalleryFrame1
@onready var _image_2 := $Images/GalleryFrame2
@onready var _image_3 := $Images/GalleryFrame3

func _ready():
	$CanvasLayer/BtnPrevious.visible = false
	$CanvasLayer/BtnNext.visible = false
	for gallery_frame in [_image_1, _image_2, _image_3]:
		gallery_frame.position.y = - gallery_frame.position.y / 2
		gallery_frame.visible = false
	
	if DataRepository.is_data_info_loaded:
		_init_gallery()
	else:
		DataRepository.connect("data_info_loaded",Callable(self,"_init_gallery"))

func _init_gallery():
	_image_names = DataRepository.get_image_names()
	_show_current_images(true)


func _show_current_images(skip_hide_animation: bool = false):
	$CanvasLayer/BtnPrevious.visible = false
	$CanvasLayer/BtnNext.visible = false
	
	_calculate_current_position()
	
	
	var current_image_names = Array(_image_names).slice(_current_position, _current_position + MAX_IMAGE_COUNT)
	var visible_images := []
	# TODO: Make dependent checked MAX_IMAGE_COUNT
	if current_image_names.size() == 3:
		visible_images = [_image_1, _image_2, _image_3]
	elif current_image_names.size() == 2:
		visible_images = [_image_1, _image_3]
	else:
		visible_images = [_image_2]
	
	var old_visible_images := []
	for gallery_frame in [_image_1, _image_2, _image_3]:
		if gallery_frame.visible:
			old_visible_images.append(gallery_frame)
	
	if not skip_hide_animation:
		$AnimationPlayer.play("hide_%s_images" % old_visible_images.size())
		await $AnimationPlayer.animation_finished
		
	for gallery_frame in old_visible_images:
		gallery_frame.visible = false
	
	var loaded_images = []
	var image_paths = []
	for image_name in current_image_names:
		var image = await DataRepository.get_image(image_name)
		loaded_images.append(image)
		image_paths.append(DataRepository.get_image_path(image_name))
	
	for i in visible_images.size():
		var gallery_frame := visible_images[i] as GalleryFrame
		var texture = ImageTexture.create_from_image(loaded_images[i])
		gallery_frame.image_texture = texture
		gallery_frame.visible = true
		if gallery_frame.is_connected("clicked",Callable(self,"_on_GalleryFrame_clicked")):
			gallery_frame.disconnect("clicked",Callable(self,"_on_GalleryFrame_clicked"))
		gallery_frame.connect("clicked",Callable(self,"_on_GalleryFrame_clicked").bind(image_paths[i]))
	
	$AnimationPlayer.play("show_%s_images" % visible_images.size())
	await $AnimationPlayer.animation_finished
	
	$CanvasLayer/BtnPrevious.visible = true
	$CanvasLayer/BtnNext.visible = true


func _on_GalleryFrame_clicked(path: String):
	JavaScriptBridge.eval("window.open('%s')" % path)


func _on_BtnNext_pressed():
	_current_position = _current_position + MAX_IMAGE_COUNT
	_show_current_images()


func _on_BtnPrevious_pressed():
	_current_position = _current_position - MAX_IMAGE_COUNT
	_show_current_images()

func _calculate_current_position():
	if _current_position >= _image_names.size():
		_current_position = 0
	elif _current_position < 0:
		_current_position = _image_names.size() - _image_names.size() % MAX_IMAGE_COUNT
