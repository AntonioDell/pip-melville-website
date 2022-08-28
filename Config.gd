extends Node

var base_url: String

func _ready():
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			if "base-url" in key_value[0]:
				base_url = key_value[1]
	if !base_url:
		printerr("No command line argument for base url found! Provided arguments were: %s" % OS.get_cmdline_args())
	else:
		print("Using '%s' as base url." % base_url)
