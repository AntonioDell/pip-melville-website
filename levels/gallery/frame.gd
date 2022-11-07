extends Sprite2D

func _ready():
	place_inside_boundaries($TestSprite)

func place_inside_boundaries(image: Sprite2D):
	var image_rect = image.get_rect()
	print("Position: %s" % image_rect.position)
	print("Size: %s" % image_rect.size)
	print("Center: %s" % image_rect.get_center())
	print("End: %s" % image_rect.end)
	
	
