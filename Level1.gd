extends Node


onready var image_url = "%s/data/images/" % $"/root/Config".base_url

func _ready():
	$HTTPRequest.connect("request_completed", self, "_images_loaded")
	var error = $HTTPRequest.request("%s/image1.png" % image_url)
	if error != OK:
		printerr(error)
	
func _images_loaded(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		printerr("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	$DebugImage.texture = texture
