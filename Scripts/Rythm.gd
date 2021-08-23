extends Node2D

var hp = 50
var score = 0
var combo = 0

onready var hp_bar = $HPBar
onready var bar_tween = $HPBar/Tween

var missSFX = []

export (Script) var song

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

var bpm

const TARGET_Y = 680
const SPAWN_Y = -10
const DIST_TO_TARGET = TARGET_Y - SPAWN_Y

var song_position = 0.0
var last_spawned_beat = 0
var sec_per_beat

var pattern_index = 0
var pattern_beats
var next_pattern_beat
var pattern

var lane = 0
var note = load("res://Scenes/Note.tscn")
var instance

var lanes = [Vector2(600, SPAWN_Y), Vector2(700, SPAWN_Y), Vector2(800, SPAWN_Y)]
var lane_amount = lanes.size()

export var miss_damage = 3

func _ready():
	randomize()
	$Conductor.play_with_beat_offset(8)
	
	pattern_beats = FirstSong.notes.keys()
	bpm = FirstSong.bpm
	for i in range(1, 9):
		missSFX.append(load("res://Sounds/miss" + str(i) + ".ogg"))


func _input(event):
	if event.is_action("escape"):
		if get_tree().change_scene("res://Scenes/Menu.tscn") != OK:
			print ("Error changing scene to Menu")

func _on_Conductor_beat(position_beats, position_measure):
	Global.camera.shake(30, .1, 30)
	
	print("measure: " + str(position_measure))
	print("beat: " + str(position_beats))
	
	next_pattern_beat = pattern_beats[pattern_index + 1]
	
	if position_beats == next_pattern_beat:
		pattern_index += 1
	
	pattern = FirstSong.notes.get(pattern_beats[pattern_index])
	if pattern:
		_spawn_notes(pattern[position_measure - 1])

func _spawn_notes(to_spawn):
	if(to_spawn > 0):
		var i = 0
		
		if(to_spawn == lane_amount):
			
			while(i < to_spawn):
				instance = note.instance()
				instance.initialize(i)
				add_child(instance)
				i += 1
		else:
			var occupied_lanes := []
			while(i < to_spawn):

				while(true):
					lane = randi() % lane_amount
					if !occupied_lanes.has(lane):
						occupied_lanes.append(lane)
						break

				instance = note.instance()
				instance.initialize(lanes[lane], DIST_TO_TARGET)
				add_child(instance)
				i += 1


func increment_score(by):
	if by > 0:
		combo += 1
	else:
		miss()
	
	if by == 3:
		great += 1
	elif by == 2:
		good += 1
	elif by == 1:
		okay += 1
	else:
		missed += 1
	
	
	score += by * combo
	$Label.text = str(score)
	if combo > 0:
		$Combo.text = str(combo) + " combo!"
		if combo > max_combo:
			max_combo = combo
	else:
		$Combo.text = ""

func increase_hp():
	hp += 1
	
	update_hp_bar()
	
func miss():
	combo = 0
	$Combo.text = ""
	
	hp -= miss_damage
	update_hp_bar()
	Global.camera.shake(100, .5, 100)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$SFXPlayer.stream = missSFX[rng.randi_range(0,7)]
	$SFXPlayer.play()
	
	if hp <= 0:
		game_over()
	

func update_hp_bar():
	hp = clamp(hp, hp_bar.min_value, hp_bar.min_value)
	bar_tween.interpolate_property(hp_bar, "value", hp_bar.value, hp, .5, Tween.EASE_OUT)
	bar_tween.start()

func game_over():
	var game_over_tween = $GameOverLayer/Tween
	var game_over_control = $GameOverLayer/Control
	
	game_over_tween.interpolate_property(game_over_control, "rect_position", Vector2(0, game_over_control.rect_position.y), Vector2.ZERO, 1)
	game_over_tween.start()
	game_over_control.set_process_unhandled_input(true)
	get_tree().paused = true
