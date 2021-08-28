extends Node2D

var lanes = []
var lane_amount
var note_path = "res://Scenes/Note"
var default_position
var speed
var speed_factor = 3.2
var climax : bool = false
var songs : Array

export (Color, RGB) var green
export (Color, RGB) var blue
export (Color, RGB) var red
export (Color, RGB) var yellow
export (Color, RGB) var pink

onready var colors = [green, blue, red, yellow, pink]

func _ready():
	pass
	
func initialize():
	songs = [load("res://Song Objects/FirstSong.tscn").instance(), load("res://Song Objects/SecondSong.tscn").instance(), load("res://Song Objects/ThirdSong.tscn").instance()]
	var bpm = songs[Global.song_index].bpm
	var sec_per_beat : float = 60.0/bpm
	speed = 800/(sec_per_beat*4)
	get_lanes()
	
	if(has_node("Song")):
		var song = $Song
		remove_child(song)
		song.queue_free()
		
	add_child(songs[Global.song_index])
	print(get_node("Song"))
	$Song.position = Vector2.ZERO
	
func set_offset(song_offset : int):
	$Song.position.y += song_offset * 200

func _physics_process(delta):
	if has_node("Song"):
		$Song.global_position.y += delta * speed

func get_lanes():
	lanes.clear()
	for button in get_tree().get_nodes_in_group("button"):
		var pos = button.position.x
		lanes.append(pos)
	lane_amount = lanes.size()

func _on_Area2D_area_entered(area):
	var pos = area.position.x
	var lane = 0
	var note = null
	
	if area.is_in_group("note"):
		note = area
		lane = lanes.find(pos)
		area.add_to_group("visible")
	elif area.is_in_group("trail"):
		lane = lanes.find(area.get_parent().position.x)
		note = area.get_parent().get_node("Note")
		area.get_parent().default_color = colors[lane]

	if climax:
		note.get_node("AnimatedSprite").modulate = Color(2, 2, 2)
		lane += 5
		
	note.get_node("AnimatedSprite").frame = lane
	
#	if note.get_node("AnimatedSprite").frame == 4:
#		print("cowabunga")
