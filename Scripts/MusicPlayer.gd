extends Node

onready var musicPlayer = $AudioStreamPlayer
var position : float = 0
var musicPlaying : String = ""

func _ready():
	pass

func change_music(music : String, pos : float):
	
	if musicPlaying != music:
		position = pos
		musicPlaying = music
		if music == "Stop":
			position = 0
			musicPlayer.stop()
		else:
			if position <= -1:
				position = musicPlayer.get_playback_position()
			musicPlayer.stop()
			musicPlayer.stream = load(music)
			musicPlayer.play(position)
