extends Node

var whoosh_1: AudioStreamWAV = preload("res://levels/map/assets/whoosh_1.wav")
var whoosh_2: AudioStreamWAV = preload("res://levels/map/assets/whoosh_2.wav")
var clack_1: AudioStreamWAV = preload("res://levels/gallery/assets/clack_1.wav")
var creak_1: AudioStreamWAV = preload("res://levels/gallery/assets/creak_1.wav")

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func play_whoosh_1():
	_play_audio(whoosh_1)

func play_whoosh_2():
	_play_audio(whoosh_2)
	
func play_clack_1():
	_play_audio(clack_1)
	
func play_creak_1():
	_play_audio(creak_1)

func _play_audio(stream: AudioStream):
	if audio_player.playing:
		audio_player.stop()
	if audio_player.stream != stream:
		audio_player.stream = stream 
	audio_player.play()
