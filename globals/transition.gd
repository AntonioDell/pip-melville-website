extends CanvasLayer

# STORE THE SCENE PATH
var next_scene: PackedScene

## Play fade animation and load the given scene.
func fade_to(scene: PackedScene):
	self.next_scene = scene
	$AnimationPlayer.play("fade")

func _change_scene():
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
		next_scene = null
