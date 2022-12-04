extends Node


signal data_info_loaded


## Dicctionary containing all meta information on the S3 files.
## 
## Example: A file stored as '/some/arbitrary/folders/sample.png' will be contained as
## {"some": {"arbitrary": {"folders": {"sample.png": {"path": "<url to retrieve this file>", "size": <file size>} }}}}
var _data_info := {}

## If true, it is safe to request data through the provided methods.
var is_data_info_loaded := false

@onready var base_url = Config.base_url


func _ready():
	_reload_data_info()


## Get all available names of images in the repository.
func get_image_names() -> Array:
	# Our AWS bucket is setup with the folder /data/images
	if not _data_info.has("data") or not _data_info["data"].has("images"):
		return []
	var name_list = []
	for image_name in _data_info["data"]["images"]:
		# On AWS buckets the folders get their own xml entry -> image with empty name gets parsed
		# This if statement is not necessary with linode object storage
		if image_name != "":
			name_list.push_back(image_name)
	return name_list


## Get web path for image name
func get_image_path(name: String) -> String:
	if not _data_info["data"]["images"].has(name):
		printerr("DataRepository: No image named %s exists." % name);
		return ""
	return _data_info["data"]["images"][name]["path"]


## Get the image with the associated name.
## Since this is an async operation, the caller must wait for the "completed" signal.
##
## Usage: var image = await DataRepository.get_image(name).completed
func get_image(name: String):
	if not _data_info["data"]["images"].has(name):
		printerr("DataRepository: No image named %s exists." % name);
		return null
	
	var error = $HTTPRequest.request(_data_info["data"]["images"][name]["path"])
	var response = await $HTTPRequest.request_completed 
	if error != OK:
		return null 
	
	# request_completed emits result, response_code, headers and body
	# we are only interested in body -> index 3
	var body = response[3]
	var image = Image.new()
	var image_type = name.split(".")[-1]
	# For now we only accept png, jpg and bmp images
	match image_type:
		"png": error = image.load_png_from_buffer(body)
		"jpg", "jpeg": error = image.load_jpg_from_buffer(body)
		"bmp": error = image.load_bmp_from_buffer(body)
		_: 
			printerr("DataRepository: Unsupported image type '%s' for image '%s'" % [image_type, name])
			error = FAILED
	if error != OK:
		return null
	return image


## Internal method.
##
## Reload the necessary informations to load data from S3 bucket
func _reload_data_info():
	print("DataRepository: Reload data info...")
	is_data_info_loaded = false
	# A request to the S3 base_url and 'Accept: applicaiton/xml' will return a list of all resources
	# inside the S3 bucket in XML format
	var error = $HTTPRequest.request(base_url, ["Accept: application/xml"])
	if error != OK:
		printerr(error)
		return
	var result = await $HTTPRequest.request_completed
	# The result XML needs to be parsed node by node
	var parser := XMLParser.new()
	var body = result[3]
	parser.open_buffer(body)
	while parser.read() == OK:
		# We only care about <Contents> node, since this contains information on all stored files
		if(parser.get_node_type() == XMLParser.NODE_ELEMENT && parser.get_node_name() == "Contents"):
			_parse_contents(parser)
	print("DataRepository: Reload finished.")
	is_data_info_loaded = true
	emit_signal("data_info_loaded")


## Internal method.
## 
## Parse the <Contents> node and extract information about all files stored inside the S3 bucket.
func _parse_contents(parser: XMLParser):
	var end_tags_to_ignore := 0
	var ignore_end_tag := false
	var last_data_key := ""
	var current_node_name := ""
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:  
				end_tags_to_ignore += 1
				current_node_name = parser.get_node_name()
			XMLParser.NODE_TEXT:
				if current_node_name == "Key":
					var key = parser.get_node_data()
					if _data_info.has(key):
						printerr("DataRepository: Key %s already assigned. Duplicate will be ignored.");
					else:
						_create_data_info_entry(key)
						last_data_key = key
				elif current_node_name == "Size" and last_data_key != "":
					_add_size_to_data_info(last_data_key, parser.get_node_data().to_int())
			XMLParser.NODE_ELEMENT_END:
				if end_tags_to_ignore > 0:
					end_tags_to_ignore -= 1
				else:
					break
			_: pass


func _create_data_info_entry(key: String):
	var key_parts := key.split("/")
	var info_to_add = {"path": "%s/%s" % [base_url, key], "size": -1}
	var reference_dict := _data_info
	for i in key_parts.size():
		var part := key_parts[i]
		if i == key_parts.size()-1:
			reference_dict[part] = info_to_add
		elif reference_dict.has(part):
			reference_dict = reference_dict[part]
		else:
			reference_dict[part] = {}
			reference_dict = reference_dict[part]


func _add_size_to_data_info(key: String, size: int):
	var key_parts := key.split("/")
	var reference_dict := _data_info
	for part in key_parts:
		reference_dict = reference_dict[part]
	if reference_dict.has("size"):
		reference_dict["size"] = size
	else:
		printerr("DataRepository: Tried to set size for key '%s', but no data info exists for that key." % key)
