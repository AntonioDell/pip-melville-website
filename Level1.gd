extends Node

func _ready():
	$HTTPRequest.connect("request_completed", self, "_images_loaded")
	$HTTPRequest.request("http://www.mocky.io/v2/5185415ba171ea3a00704eed")
	pass
	
func _images_loaded(result, response_code, headers, body):
	pass
