extends Node2D

var bpm = 115
var measures = 4

var song_start = 8
var song_end = 406

var neighbor_start = 12
var neighbor_end = 380

var climax = -1

var stream_path = "res://Sounds/Sounds_song.ogg"

var notes = {
	1:
		[0, 0, 0, 1],
	36:
		[1, 1, 1, 1],
	98:
		[2, 0, 1, 0],
	132:
		[0, 2, 0 ,2],
	162:
		[2, 2, 1, 1],
	194:
		[2, 2, 1, 2],
	228:
		[0, 2, 1, 2],
	258:
		[1, 2, 1, 2],
	288:
		[0, 2, 0, 2],
	322:
		[3, 2, 2, 1],
	388:
		[1, 0, 0, 0]
}
