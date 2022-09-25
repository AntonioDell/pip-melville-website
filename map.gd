extends Node2D


signal _move_completed


## Holds all previously calculated shortest path maps for the respective key.
## key: LevelIndicator.map_position
## value: { LevelIndicator.map_position: { shortest_distance: int, previous_pos: LevelIndicator.map_position } }
var _shortest_path_maps := {}
var _is_moving := false

@onready var _level_indicators := get_tree().get_nodes_in_group("level_indicators")
@onready var _map_paths: Array = get_tree().get_nodes_in_group("map_paths")
@onready var _player := $Player
@onready var _player_position : int = PlayerData.map_position

func _ready():
	for indicator in _level_indicators:
		indicator.connect("clicked",Callable(self,"_on_LevelIndicator_clicked"))
		if indicator.map_position == _player_position:
			_player.global_position = indicator.global_position


func _on_LevelIndicator_clicked(level_indicator: LevelIndicator):
	if _is_moving:
		return
	var current_indicator := _get_current_indicator()
	if current_indicator != level_indicator:
		_move_between(current_indicator, level_indicator)
		await self._move_completed
	_is_moving = false
	if level_indicator.scene_to_load:
		$"/root/Transition".fade_to(level_indicator.scene_to_load)


func _get_current_indicator() -> LevelIndicator:
	var result: LevelIndicator
	for indicator in _level_indicators:
		if indicator.map_position == _player_position:
			result = indicator
			break
	return result


func _move_between(current_indicator: LevelIndicator, next_indicator: LevelIndicator):
	_is_moving = true
	if not _shortest_path_maps.has(_player_position):
		_create_shortest_path_map(current_indicator)
	var shortest_path_map = _shortest_path_maps[_player_position]
	
	var traversions = _get_path_traversion_between(current_indicator, next_indicator, shortest_path_map)
	if traversions.size() == 0:
		print("No path between %s and %s exists." % [current_indicator.map_position, next_indicator.map_position])
		emit_signal("_move_completed")
		return
	for i in traversions.size():
		var path := traversions[i].path as MapPath
		var traverse_backwards := traversions[i].traverse_backwards as bool
		path.traverse_path(_player, traverse_backwards)
		await path.traversal_finished
	
	PlayerData.map_position = next_indicator.map_position
	_player_position = next_indicator.map_position
	emit_signal("_move_completed")


## Uses dijkstra algortihm to create a shortest path map for the source indicator
## FIXME: This algorithm behaves differently on exports than on editor play
func _create_shortest_path_map(source: LevelIndicator):
	# Init
	var visited := {}
	var unvisited := {}
	var result := {}
	for i in _level_indicators.size():
		var indicator: LevelIndicator = _level_indicators[i]
		var pos = indicator.map_position
		unvisited[pos] = indicator
		result[pos] = {"shortest_distance": INF, "previous_pos": null}
	result[source.map_position] = {"shortest_distance": 0, "previous_pos": null}
	# Iterate all unvisited nodes
	while unvisited.size() > 0:
		var current_pos := _find_shortest(unvisited, result)
		var current_indicator = unvisited[current_pos] as LevelIndicator
		var neighbours = _get_unvisited_neighbours(current_indicator, visited)
		for neighbour_pos in neighbours:
			# Check neighbour results of current node
			var neighbour_indicator := unvisited[neighbour_pos] as LevelIndicator
			var new_distance = result[current_pos].shortest_distance + 1 # Weight of all paths is 1
			if new_distance < result[neighbour_pos].shortest_distance:
				# Update neighbour results
				result[neighbour_pos].shortest_distance = new_distance
				result[neighbour_pos].previous_pos = current_pos
		unvisited.erase(current_pos)
		visited[current_pos] = current_indicator
	
	_shortest_path_maps[source.map_position] = result


func _find_shortest(unvisited: Dictionary, info_map: Dictionary) -> int:
	var shortest_map_pos := -1
	for pos in unvisited:
		if shortest_map_pos == -1 or \
		info_map[shortest_map_pos].shortest_distance > info_map[pos].shortest_distance:
			shortest_map_pos = pos
	return shortest_map_pos


func _get_unvisited_neighbours(indicator: LevelIndicator, visited: Dictionary) -> Array:
	var result := []
	for path in _map_paths:
		var start_pos := (path as MapPath).start_map_position
		var end_pos := (path as MapPath).end_map_position
		if start_pos == indicator.map_position and not visited.has(end_pos):
			result.push_back(end_pos)
		elif end_pos == indicator.map_position and path.is_two_way and not visited.has(start_pos):
			result.push_back(start_pos)
	return result


func _get_path_traversion_between(source: LevelIndicator, target: LevelIndicator, shortest_path_map: Dictionary) -> Array:
	var paths := []
	var current_pos := target.map_position
	while current_pos != source.map_position:
		var previous_pos = shortest_path_map[current_pos].previous_pos
		if previous_pos == null:
			return []
		for i in _map_paths.size():
			var path := _map_paths[i] as MapPath
			if path.start_map_position == previous_pos and path.end_map_position == current_pos:
				paths.push_front({"path": path, "traverse_backwards": false})
				break
			elif path.is_two_way and path.start_map_position == current_pos and path.end_map_position == previous_pos:
				paths.push_front({"path": path, "traverse_backwards": true})
				break
		current_pos = previous_pos
	return paths


