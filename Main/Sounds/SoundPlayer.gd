extends Node


onready var audioStreamPlayer = $AudioPlayers/AudioStreamPlayer

func play_sound():
	audioStreamPlayer.play()
	
	
