@tool 
class_name MapPath
extends Path2D

signal traversal_finished

@export var start: NodePath:
	get:
		return start # TODOConverter40 Non existent get function 
	set(mod_value):
		start = mod_value
		_init_curve()

@export var end: NodePath:
	get:
		return end # TODOConverter40 Non existent get function 
	set(mod_value):
		end = mod_value
		_init_curve()

@export var is_two_way := false

var start_map_position: int
var end_map_position: int

var _player_node: Node2D

func _ready():
	print("is_two_way=%s" % is_two_way)
	_init_curve()
	if not Engine.is_editor_hint():
		_update_map_positions()

func _init_curve():
	if not Engine.is_editor_hint() or curve:
		return
	update_configuration_warnings()
	if start == null or end == null:
		return
	var start_node: Node2D = get_node(start)
	var end_node: Node2D = get_node(end)
	var new_curve = Curve2D.new()
	new_curve.add_point(start_node.global_position)
	new_curve.add_point(end_node.global_position)
	curve = new_curve


func _update_map_positions():
	if Engine.is_editor_hint():
		return
	if start:
		start_map_position = (get_node(start) as LevelIndicator).map_position
	if end:
		end_map_position = (get_node(end) as LevelIndicator).map_position

func _get_configuration_warnings():
	if start == null:
		return "MapPath needs start node."
	elif end == null:
		return "MapPath needs end node."
	elif not get_node(start) is LevelIndicator:
		return "MapPath start must be a LevelIndicator node."
	elif not get_node(end) is LevelIndicator:
		return "MapPath end must be a LevelIndicator node."
	return ""


func traverse_path(player: Node2D, traverse_backwards: bool):
	# TODO: Set player to start or end (based checked traverse_backwards)
	var traversion_start := start if not traverse_backwards else end
	var progress_ratio := 0.0 if not traverse_backwards else 1.0
	var target_unit_offset := 1.0 if not traverse_backwards else 0.0
	$PathFollow2D.progress_ratio = progress_ratio
	# TODO: Set PathFollow2D as parent of player
	_reparent(player, $PathFollow2D)
	# TODO: Yield Tween PathFollow2D to 1 or 0 (based checked current unit)
	var tween = get_tree().create_tween()
	tween.tween_property($PathFollow2D, "progress_ratio", target_unit_offset, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	await tween.finished
	# TODO: Emit signal traversion_completed
	emit_signal("traversal_finished")


func _reparent(child: Node2D, new_parent: Node2D):
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	child.position = Vector2.ZERO
	new_parent.add_child(child)
