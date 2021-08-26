extends Node2D

var hp
var score
var combo

onready var hp_bar = $CanvasLayer/HPBar
onready var bar_tween = $CanvasLayer/HPBar/Tween

onready var combo_label = $CanvasLayer/ScoreIndicator/Combo
onready var score_label = $CanvasLayer/ScoreIndicator/Score
onready var results_screen = $CanvasLayer/ResultsScreen


var missSFX = []

export (Script) var song

var max_combo
var great
var good
var okay
var missed

var showing_results = false

var songs = [FirstSong, SecondSong, ThirdSong]
var song_index = 0

var bpm

const TARGET_Y = 680
const SPAWN_Y = -10
const DIST_TO_TARGET = TARGET_Y - SPAWN_Y

var song_position
var last_spawned_beat
var sec_per_beat

var pattern_index = 0
var pattern_beats
var next_pattern_beat
var pattern
export var transparency_amount : float = 0.6
var default_alpha
var default_overlay_alpha
var default_shader_scale
export var shader_reduction = .7
var default_light_energy
export var light_intense = 1.5
export var lightbulb_glow = .4

var song_started : bool = false

onready var overlay = get_parent().get_node("ColorOverlay")
onready var vignette = get_parent().get_node("Vignette")

var lane = 0
var note_path = "res://Scenes/Note"
var trail = load("res://Scenes/Trail.tscn")
var filter = load("res://Sounds/Filter.tres")
var instance
var climax : bool = false
var supressing : bool = false
export var supress_threshold = 1

var lanes = []
var lane_amount

var lightbulb
var lightbulb_tween
var lightbulb_sprite

var colors = ["Green", "Blue", "Red", "Yellow", "Pink"]

export (NodePath) var tv_screen_path
var tv_screen
export (float) var miss_damage = 3

func _ready():
	randomize()
	get_lanes()

	default_shader_scale = vignette.get_material().get("shader_param/SCALE")
	tv_screen = get_node(tv_screen_path)
	lightbulb = get_parent().get_node("Lightbulb")
	lightbulb_tween = lightbulb.get_node("Tween")
	lightbulb_sprite = lightbulb.get_node("LightbulbSprite")
	default_light_energy = lightbulb.energy
	default_alpha = modulate.a
	default_overlay_alpha = overlay.modulate.a
	for i in range(1, 9):
		missSFX.append(load("res://Sounds/miss" + str(i) + ".ogg"))

	initialize()
	start_song(8)

func _process(delta):
	if $Neighbor.visiting && tv_screen.animation != "skull":
		tv_screen.animation = "skull"
	elif !$Neighbor.visiting && tv_screen.animation != "default":
		tv_screen.animation = "default"

func start_song(offset : int):
	initialize()
	$Conductor.initialize(songs[song_index])
	$Conductor.play_with_beat_offset(offset)
	
	# if song_index == 0:
	# 	$Conductor.play_from_beat(390, offset)
	# else:
	# 	$Conductor.play_with_beat_offset(offset)

func _input(event):
	if event.is_action("escape"):
		if get_tree().change_scene("res://Scenes/Menu.tscn") != OK:
			print ("Error changing scene to Menu")

	if event.is_action_pressed("supress"):
		supressing = true
		$Tween.stop_all()
		$Tween.interpolate_property($ColorRect, "modulate:a", modulate.a, default_alpha - transparency_amount, .2, Tween.EASE_IN)
		$Tween.interpolate_property(overlay, "modulate:a", overlay.modulate.a, 0, .2, Tween.EASE_IN)

		var shader_scale = vignette.get_material().get("shader_param/SCALE")
		$Tween.interpolate_property(vignette.get_material(), "shader_param/SCALE", shader_scale, default_shader_scale + shader_reduction, .2, Tween.EASE_IN)
		$Tween.start()
		AudioServer.add_bus_effect(2, filter, 0)

	if event.is_action_released("supress"):

		supressing = false
		$Tween.stop_all()
		$Tween.interpolate_property($ColorRect, "modulate:a", modulate.a, 1, .2, Tween.EASE_OUT)
		$Tween.interpolate_property(overlay, "modulate:a", overlay.modulate.a, default_overlay_alpha, .2, Tween.EASE_OUT)

		var shader_scale = vignette.get_material().get("shader_param/SCALE")
		$Tween.interpolate_property(vignette.get_material(), "shader_param/SCALE", shader_scale, default_shader_scale, .2, Tween.EASE_OUT)

		$Tween.start()
		$Timer.stop()
		AudioServer.remove_bus_effect(2, 0)

	if showing_results:
		if event.is_action("ui_accept"):
			results_screen.get_node("AnimationPlayer").play_backwards("move")
			get_parent().get_node("AnimationPlayer").play("to_song_" + str(song_index + 1))

func _on_Conductor_beat(position_beats, position_measure):
	if !song_started && position_beats >= songs[song_index].song_start:
		song_started = true

	if song_started:
		
		if position_measure != 4:
			Global.camera.zoom_cam(.002, .05)
		else:
			Global.camera.zoom_cam(.003, .06)

		var new_glowness = lightbulb_sprite.modulate.r + lightbulb_glow
		var glow_color = Color(new_glowness, new_glowness, new_glowness)

		if !supressing:
			lightbulb.energy = light_intense
			lightbulb_sprite.modulate = glow_color

		lightbulb_tween.interpolate_property(lightbulb, "energy", lightbulb.energy, default_light_energy, .5, Tween.EASE_OUT)
		lightbulb_tween.interpolate_property(lightbulb_sprite, "modulate", lightbulb_sprite.modulate, Color(1,1,1), .5, Tween.EASE_OUT)
		lightbulb_tween.start()


	print("measure: " + str(position_measure))
	print("beat: " + str(position_beats))

	var next_pattern_index = pattern_index + 1
	if next_pattern_index < pattern_beats.size():
		next_pattern_beat = pattern_beats[pattern_index + 1]

	if position_beats == next_pattern_beat:
		pattern_index += 1

	pattern = songs[song_index].notes.get(pattern_beats[pattern_index])
	if pattern:
		_spawn_notes(pattern[position_measure - 1])

	if position_beats == songs[song_index].neighbor_start:
		$Neighbor.start()
	elif position_beats == songs[song_index].neighbor_end:
		$Neighbor.end()

	if position_beats == songs[song_index].climax:
		enter_climax()
		
	if position_beats >= songs[song_index].song_end:
		$Conductor.stop_song()
		song_index += 1
		results()		

func _spawn_notes(to_spawn):
	if(to_spawn > 0):
		var i = 0

		if(to_spawn == lane_amount):

			while(i < to_spawn):
				var color = colors[i]
				var note = load(note_path + color + ".tscn")

				instance = note.instance()
				instance.initialize(lanes[i], i, DIST_TO_TARGET, climax)
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

				var color = colors[lane]
				var note = load(note_path + color + ".tscn")
				instance = note.instance()
				instance.initialize(lanes[lane], lane, DIST_TO_TARGET, climax)
				add_child(instance)

				i += 1

func increment_score(by):
	if by > 0:
		combo += 1
	else:
		miss(miss_damage)

	if by == 3:
		great += 1
	elif by == 2:
		good += 1
	elif by == 1:
		okay += 1
	else:
		missed += 1


	score += by * combo
	score_label.text = str(score)
	if combo > 0:
		combo_label.text = str(combo) + "x"
		if combo > max_combo:
			max_combo = combo
	else:
		combo_label.text = "0x"

func increase_hp():
	hp += 1

	update_hp_bar()

func miss(damage):
	combo = 0
	combo_label.text = "0x"

	hp -= damage
	update_hp_bar()
#	Global.camera.shake(100, .5, 100)
	if(!supressing):
		$Glitch.start()

		var rng = RandomNumberGenerator.new()
		rng.randomize()
		$SFXPlayer.stream = missSFX[rng.randi_range(0,7)]
		$SFXPlayer.play()

	if hp <= 0:
		$Glitch.end()
		$GameOverLayer/Control.start()

func initialize():
	hp = 50
	score = 0
	combo = 0
	
	max_combo = 0
	great = 0
	good = 0
	okay = 0
	missed = 0
	
	song_position = 0.0
	last_spawned_beat = 0
	song_started = false
	
	pattern_index = 0
	pattern_beats = songs[song_index].notes.keys()
	bpm = songs[song_index].bpm
	next_pattern_beat = null
	pattern = null
	
	score_label.text = "0"
	combo_label.text = "0x"
	update_hp_bar()

func update_hp_bar():
	hp = clamp(hp, hp_bar.min_value, hp_bar.max_value)
	bar_tween.interpolate_property(hp_bar, "value", hp_bar.value, hp, .5, Tween.EASE_OUT)
	bar_tween.start()

func enter_climax():
	climax = true

	for button in get_tree().get_nodes_in_group("button"):
		button.frame = 1

	for note in get_tree().get_nodes_in_group("note"):
		note.get_node("AnimatedSprite").frame = 1

func get_lanes():
	lanes.clear()
	for button in get_tree().get_nodes_in_group("button"):
		var pos = Vector2(button.global_position.x, SPAWN_Y)
		lanes.append(pos)
	lane_amount = lanes.size()

func add_button(btn_index : int):
	$Buttons/AnimationPlayer.play("add_lane_" + str(btn_index))

func reparent_button(num : int):
	var button = get_node("Button" + str(num))
	var prev_global_position = button.global_position
	remove_child(button)
	$Buttons.add_child(button)
	button.global_position = prev_global_position
	button.set_owner($Buttons)

func results():
	showing_results = true
	results_screen.get_node("ScoreLabel").text = str(score)
	results_screen.get_node("MaxComboLabel").text = str(max_combo)
	results_screen.get_node("GreatLabel").text = str(great)
	results_screen.get_node("GoodLabel").text = str(good)
	results_screen.get_node("OkayLabel").text = str(okay)
	results_screen.get_node("MissedLabel").text = str(missed)
	results_screen.get_node("AnimationPlayer").play("move")
