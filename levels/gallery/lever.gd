extends Node2D


## direction will be either [Vector2.RIGHT] or [Vector2.LEFT], depending on which direction the lever was pulled
signal triggered(direction: Vector2)

@export var is_blocked := false
@export var max_drag_length: float
@export_range(0, 90, .1) var max_rotation
@export_exp_easing var rotation_easing: float
@export_range(0, 90, .1) var max_wiggle: float


var _is_dragged := false
var _is_snapping_back := false
var _drag_start_position := -Vector2.ONE
var _mouse_mode: int


@onready var _handle: Node2D = $Handle


func _process(delta):
	if not _is_dragged or _is_snapping_back:
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_is_dragged = false
		Input.mouse_mode = _mouse_mode
		return
	
	_rotate_handle()


func _on_GrabArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
	and not _is_snapping_back:
		if is_blocked:
			_wiggle()
		else:
			# Start drag
			_is_dragged = true
			_mouse_mode = Input.mouse_mode
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			_drag_start_position = event.global_position


func _wiggle(): 
	GlobalAudio.play_creak_1()
	var wiggle_tween = create_tween()
	wiggle_tween.tween_property(_handle, "rotation", deg_to_rad(max_wiggle), .25).set_ease(Tween.EASE_IN)
	wiggle_tween.tween_property(_handle, "rotation", -deg_to_rad(max_wiggle), .25).set_ease(Tween.EASE_IN)
	wiggle_tween.tween_property(_handle, "rotation", 0, .5).set_ease(Tween.EASE_IN)


func _rotate_handle():
	var delta_x := get_global_mouse_position().x - _drag_start_position.x
	var drag_ratio = ease(clamp(inverse_lerp(0, max_drag_length, abs(delta_x)), 0, 1), rotation_easing)
	var lerped_angle = lerp_angle(0, deg_to_rad(max_rotation), drag_ratio)
	_handle.rotation = sign(delta_x) * lerped_angle
	
	if abs(_handle.rotation) >= deg_to_rad(max_rotation-0.01):
		GlobalAudio.play_clack_1()
		_is_dragged = false
		_is_snapping_back = true
		Input.warp_mouse(_drag_start_position)
		Input.mouse_mode = _mouse_mode
		emit_signal("triggered", Vector2.RIGHT if sign(delta_x) > 0 else Vector2.LEFT)
		var snap_back_tween := create_tween()
		snap_back_tween.tween_property(_handle, "rotation", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		await snap_back_tween.finished
		_is_snapping_back = false
