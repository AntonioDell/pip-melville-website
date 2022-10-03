extends Node

const MAX_IMAGE_COUNT := 3
const TWEEN_DELAY := .5

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
	_show_current_images(true, true)


func _show_current_images(enter_from_left: bool = true, skip_hide_animation: bool = false):
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
		var exit_tween := create_tween().set_parallel()
		var old_positions := _get_frame_positions(old_visible_images.size())
		var exit_direction := "exit" if enter_from_left else "entry"
		for i in old_visible_images.size():
			var index := (-i - 1 if enter_from_left else i) as int
			var frame := old_visible_images[index] as GalleryFrame
			_tween_frame(exit_tween, frame, old_positions[exit_direction][index], TWEEN_DELAY*i, enter_from_left)
		await exit_tween.finished
		
	for gallery_frame in old_visible_images:
		gallery_frame.visible = false
	
	var loaded_images = []
	var image_paths = []
	for image_name in current_image_names:
		var image = await DataRepository.get_image(image_name)
		loaded_images.append(image)
		image_paths.append(DataRepository.get_image_path(image_name))
	
	var positions := _get_frame_positions(visible_images.size())
	var enter_direction := "entry" if enter_from_left else "exit"
	for i in visible_images.size():
		var gallery_frame := visible_images[i] as GalleryFrame
		var texture = ImageTexture.create_from_image(loaded_images[i])
		gallery_frame.image_texture = texture
		gallery_frame.position = positions[enter_direction][i]
		gallery_frame.visible = true
		if gallery_frame.is_connected("clicked",Callable(self,"_on_GalleryFrame_clicked")):
			gallery_frame.disconnect("clicked",Callable(self,"_on_GalleryFrame_clicked"))
		gallery_frame.connect("clicked",Callable(self,"_on_GalleryFrame_clicked").bind(image_paths[i]))
		
	var entry_tween := create_tween().set_parallel()
	for i in visible_images.size():
		var index := (-i - 1 if enter_from_left else i) as int
		var gallery_frame := visible_images[index] as GalleryFrame
		_tween_frame(entry_tween, gallery_frame, positions["visible"][index], TWEEN_DELAY*i, enter_from_left)
	await entry_tween.finished
	
	$CanvasLayer/BtnPrevious.visible = true
	$CanvasLayer/BtnNext.visible = true

func _get_frame_positions(number_of_frames: int) -> Dictionary:
	var positions := {"entry": [], "visible": [], "exit": []}
	var base_node: Node2D
	if number_of_frames == 1:
		base_node = $FramePositions/SingleFrame
	elif number_of_frames == 2:
		base_node = $FramePositions/TwoFrames
	else:
		base_node = $FramePositions/ThreeFrames
	var entry_node := base_node.find_child("Entry", false, true)
	var visible_node := base_node.find_child("Visible", false, true)
	var exit_node := base_node.find_child("Exit", false, true)
	for i in number_of_frames:
		positions["entry"].push_back((entry_node.get_child(i) as Node2D).position)
		positions["visible"].push_back((visible_node.get_child(i) as Node2D).position)
		positions["exit"].push_back((exit_node.get_child(i) as Node2D).position)
	return positions


func _on_GalleryFrame_clicked(path: String):
	JavaScriptBridge.eval("window.open('%s')" % path)


func _tween_frame(tween: Tween, frame: GalleryFrame, end_position: Vector2, delay: float, move_to_right: bool) -> void:
	tween.tween_property(frame, "position", end_position, 2).set_delay(delay).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): frame.start_swinging(move_to_right)).set_delay(delay)


func _on_BtnNext_pressed():
	_current_position = _current_position + MAX_IMAGE_COUNT
	_show_current_images(true)


func _on_BtnPrevious_pressed():
	_current_position = _current_position - MAX_IMAGE_COUNT
	_show_current_images(false)

func _calculate_current_position():
	if _current_position >= _image_names.size():
		_current_position = 0
	elif _current_position < 0:
		_current_position = _image_names.size() - _image_names.size() % MAX_IMAGE_COUNT
