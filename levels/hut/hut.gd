extends Node

var _text_names: Array[String] = []
var _current_text := 0
var _is_navigation_blocked := true

func _ready():
	if DataRepository.is_data_info_loaded:
		_init_hut()
	else:
		DataRepository.connect("data_info_loaded",Callable(self,"_init_hut"))


func _init_hut():
	_text_names = DataRepository.get_text_names()
	await _show_current_text()

func _calculate_current_text():
	if _current_text >= _text_names.size():
		_current_text = 0
	elif _current_text < 0:
		_current_text = _text_names.size() -1

func _show_current_text():
	_is_navigation_blocked = true
	_calculate_current_text()
	
	var text_name = _text_names[_current_text]
	var text = await DataRepository.get_text(text_name)
	$RichTextLabel.text = "\n\n\n%s\n\n\n" % [text]
	_is_navigation_blocked = false


func _on_forward_button_pressed():
	if _is_navigation_blocked: 
		return
	_current_text = _current_text + 1
	_show_current_text()


func _on_back_button_pressed():
	if _is_navigation_blocked: 
		return
	_current_text = _current_text - 1
	_show_current_text()


func _on_mirror_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var text_path = DataRepository.get_text_path(_text_names[_current_text])
		JavaScriptBridge.eval("window.open('%s')" % text_path)
