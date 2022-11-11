extends Node

var whoosh_1: AudioStreamWAV = preload("res://levels/map/assets/whoosh_1.wav")
var whoosh_2: AudioStreamWAV = preload("res://levels/map/assets/whoosh_2.wav")

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func play_whoosh_1():
	_play_audio(whoosh_1)

func play_whoosh_2():
	_play_audio(whoosh_2)

func _play_audio(stream: AudioStream):
	if audio_player.playing:
		audio_player.stop()
	if audio_player.stream != stream:
		audio_player.stream = stream 
	audio_player.play()
