extends Node


var _map_position := 0 setget set_map_position, get_map_position


func set_map_position(new_position: int):
	_map_position = new_position


func get_map_position() -> int:
	return _map_position
