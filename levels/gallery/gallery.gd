extends Node

const MAX_IMAGE_COUNT := 3
const TWEEN_DELAY := .5

var _image_names := PackedStringArray()
var _current_position := 0

@onready var _portrait_1 := $Portraits/Portrait1
@onready var _portrait_2 := $Portraits/Portrait2
@onready var _portrait_3 := $Portraits/Portrait3
@onready var _portraits_node = $Portraits

var _portraits: Array[Frame] = []

func _ready():
	for node in _portraits_node.get_children():
		if node is Frame:
			_portraits.append(node)
	
	for portrait in _portraits:
		portrait.visible = false
	
	if DataRepository.is_data_info_loaded:
		_init_gallery()
	else:
		DataRepository.connect("data_info_loaded",Callable(self,"_init_gallery"))

func _init_gallery():
	_image_names = DataRepository.get_image_names()
	await _show_current_images(true, true)
	$Lever.is_blocked = false


func _show_current_images(enter_from_left: bool = true, skip_hide_animation: bool = false):
	_calculate_current_position()
	
	var current_image_names = Array(_image_names).slice(_current_position, _current_position + MAX_IMAGE_COUNT)
	var visible_portraits := _get_visible_portraits(current_image_names.size())

	var old_visible_portraits := []
	for portrait in _portraits:
		if portrait.visible:
			old_visible_portraits.append(portrait)
	old_visible_portraits.sort_custom(func(a: Node2D, b: Node2D): 
		return a.position.x < b.position.x
	)
	
	if not skip_hide_animation:
		var exit_tween := create_tween().set_parallel()
		var old_positions := _get_frame_positions(old_visible_portraits.size())
		var exit_direction := "exit" if enter_from_left else "entry"
		for i in old_visible_portraits.size():
			var index := (-i - 1 if enter_from_left else i) as int
			var frame := old_visible_portraits[index] as Frame
			_tween_frame(exit_tween, frame, old_positions[exit_direction][index], TWEEN_DELAY*i, enter_from_left)
		await exit_tween.finished
		
	for portrait in old_visible_portraits:
		portrait.visible = false
	
	var loaded_images = []
	var image_paths = []
	for image_name in current_image_names:
		var image = await DataRepository.get_thumbnail(image_name)
		loaded_images.append(image)
		image_paths.append(DataRepository.get_image_path(image_name))
	
	var positions := _get_frame_positions(visible_portraits.size())
	var enter_direction := "entry" if enter_from_left else "exit"
	for i in visible_portraits.size():
		var portrait := visible_portraits[i] as Frame
		if loaded_images[i] != null:
			var texture = ImageTexture.create_from_image(loaded_images[i])
			portrait.place_inside_boundaries(texture)
		portrait.position = positions[enter_direction][i]
		portrait.visible = true
		if portrait.is_connected("clicked",Callable(self,"_on_GalleryFrame_clicked")):
			portrait.disconnect("clicked",Callable(self,"_on_GalleryFrame_clicked"))
		portrait.connect("clicked",Callable(self,"_on_GalleryFrame_clicked").bind(image_paths[i]))
		
	var entry_tween := create_tween().set_parallel()
	for i in visible_portraits.size():
		var index := (-i - 1 if enter_from_left else i) as int
		var portrait := visible_portraits[index]
		_tween_frame(entry_tween, portrait, positions["visible"][index], TWEEN_DELAY*i, enter_from_left)
	await entry_tween.finished


func _get_visible_portraits(amount: int) -> Array[Frame]:
	var _amount: int = amount
	if _amount > _portraits.size() or _amount > MAX_IMAGE_COUNT:
		_amount = MAX_IMAGE_COUNT
	
	var _possible_portraits := _portraits.duplicate()
	_possible_portraits.shuffle()
	
	var result := _possible_portraits.slice(0, _amount)
	return result


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


func _tween_frame(tween: Tween, frame: Frame, end_position: Vector2, delay: float, move_to_right: bool) -> void:
	tween.tween_property(frame, "position", end_position, 2).set_delay(delay).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): frame.start_swinging(move_to_right)).set_delay(delay)


func _calculate_current_position():
	if _current_position >= _image_names.size():
		_current_position = 0
	elif _current_position < 0:
		_current_position = _image_names.size() - _image_names.size() % MAX_IMAGE_COUNT


func _on_Lever_triggered(direction: Vector2):
	$Lever.is_blocked = true
	if direction == Vector2.RIGHT:
		_current_position = _current_position + MAX_IMAGE_COUNT
		await _show_current_images(true)
	else:
		_current_position = _current_position - MAX_IMAGE_COUNT
		await _show_current_images(false)
	$Lever.is_blocked = false
