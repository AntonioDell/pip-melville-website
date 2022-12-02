class_name Frame
extends Sprite2D


signal clicked


var _boundary_points := {"min_x": INF, "min_y": INF, "max_x": -INF, "max_y": -INF}
var _boundary_rect: Rect2

@onready var image_sprite: Sprite2D = $ImageSprite


func _ready():
	for point in $ImageBoundaries.polygon:
		if point.x < _boundary_points.min_x:
			_boundary_points.min_x = point.x
		if point.y < _boundary_points.min_y:
			_boundary_points.min_y = point.y
		if point.x > _boundary_points.max_x:
			_boundary_points.max_x = point.x
		if point.y > _boundary_points.max_y:
			_boundary_points.max_y = point.y
	_boundary_rect = Rect2(\
		_boundary_points.min_x,\
		_boundary_points.min_y,\
		_boundary_points.max_x - _boundary_points.min_x,\
		_boundary_points.max_y - _boundary_points.min_y\
	)

func start_swinging(move_to_right: bool) -> void:
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop(true)
	if move_to_right:
		$AnimationPlayer.play("swing_to_right_movement")
	else:
		$AnimationPlayer.play("swing_to_left_movement")


func place_inside_boundaries(texture: ImageTexture):
	if texture.get_width() <= _boundary_rect.size.x &&\
		texture.get_height() <= _boundary_rect.size.y: 
		# Simple case: Texture fits inside boundary -> no resize necessary
		_place_texture(texture)
		return
	
	# Check which side should be shrunk to the boundary size
	var delta_width := texture.get_width() - _boundary_rect.size.x
	var delta_height := texture.get_height() - _boundary_rect.size.y
	
	var shrunk_width: int
	var shrunk_height: int
	if delta_width > delta_height:
		# Shrink width
		shrunk_width = _boundary_rect.size.x
		# Calculate aspect ratio of shrunk side
		var a = _boundary_rect.size.x / texture.get_width()
		# Shrink other side with that aspect ratio
		shrunk_height = texture.get_height() * a
	else:
		# Shrink height
		shrunk_height = _boundary_rect.size.y
		# Calculate aspect ratio of shrunk side
		var a = _boundary_rect.size.y / texture.get_height()
		# Shrink other side with that aspect ratio
		shrunk_width = texture.get_width() * a
	
	texture.set_size_override(Vector2(shrunk_width, shrunk_height))
	_place_texture(texture)


func _place_texture(texture: Texture2D):
	image_sprite.texture = texture


func _on_click_area_input_event(viewport, event, shape_idx):	
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked")
