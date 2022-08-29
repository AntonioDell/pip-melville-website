extends KinematicBody2D

export(NodePath) var player_path_follow_node: NodePath
export(PackedScene) var scene_to_load: PackedScene

onready var player_path_follow: PathFollow2D = get_node(player_path_follow_node) as PathFollow2D

var current_movement: SceneTreeTween


func _on_Level1Indicator_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && !current_movement:
		current_movement = get_tree().create_tween().bind_node(self)
		current_movement.tween_property(player_path_follow, "unit_offset", 1.0, 5.0)
		current_movement.connect("finished", self, "_movement_finished")


func _movement_finished():
	current_movement = null
	get_tree().change_scene_to(scene_to_load)
