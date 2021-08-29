extends Node2D

var hp
var score
var combo

onready var hp_bar = $CanvasLayer/HPBar/Bar
onready var bar_tween = $CanvasLayer/HPBar/Tween

onready var combo_label = $CanvasLayer/ScoreIndicator/Combo
onready var score_label = $CanvasLayer/ScoreIndicator/Score
onready var results_screen = $CanvasLayer/ResultsScreen

export (int) var play_from

var max_combo
var great
var good
var okay
var missed

var showing_results = false
onready var song_index = Global.song_index

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

export (Color, RGB) var lightbulb_purple
export (Color, RGB) var lightbulb_blue

export (NodePath) var tv_screen_path
var tv_screen
export (float) var miss_damage = 0

func _ready():
	Engine.time_scale = 1
	randomize()

	default_shader_scale = vignette.get_material().get("shader_param/SCALE")
	tv_screen = get_node(tv_screen_path)
	lightbulb = get_parent().get_node("Lightbulb")
	lightbulb_tween = lightbulb.get_node("Tween")
	lightbulb_sprite = lightbulb.get_node("LightbulbSprite")
	default_light_energy = lightbulb.energy
	default_alpha = modulate.a
	default_overlay_alpha = overlay.modulate.a

	start_song(3)

func _process(delta):
	if $Neighbor.visiting && tv_screen.animation != "skull":
		tv_screen.animation = "skull"
		$SFXPlayer.play_bell()
		
	elif !$Neighbor.visiting && tv_screen.animation != "default":
		tv_screen.animation = "default"
		$SFXPlayer.play_footsteps()

func start_song(offset : int = 4):
	song_index = Global.song_index
	$Conductor.initialize(Global.songs[song_index])
	initialize()
#	if song_index != 0:
#		play_from = 0

	$Conductor.play_from_beat(play_from, offset)

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
			showing_results = false
			results_screen.get_node("AnimationPlayer").play_backwards("move")
			Global.song_index += 1
			get_parent().get_node("AnimationPlayer").play("to_song_" + str(Global.song_index + 1))
		elif event.is_action("retry"):
			get_tree().reload_current_scene()

func _on_Conductor_beat(position_beats, position_measure):
	
	if position_beats == (Global.songs[song_index].song_start - 1):
		get_tree().call_group("player", "transit")
	
	if !song_started && position_beats >= Global.songs[song_index].song_start:
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

	if position_beats == Global.songs[song_index].neighbor_start:
		$Neighbor.start()
	elif position_beats == Global.songs[song_index].neighbor_end:
		$Neighbor.end()

	if position_beats == Global.songs[song_index].climax:
		enter_climax()

	if position_beats >= Global.songs[song_index].song_end:
		$Conductor.stop_song()
		get_tree().call_group("player", "transit_back")
		exit_climax()
#		Global.song_index += 1
		results()

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
	return

	combo = 0
	combo_label.text = "0x"

	hp -= damage
	update_hp_bar()

	if(!supressing):
		$Glitch.start()

		
		$SFXPlayer.play_miss()

	if hp <= 0:
		$Glitch.end()
		$GameOverLayer/Control.start()

func initialize():
	song_index = Global.song_index

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
	bpm = Global.songs[song_index].bpm
	
	score_label.text = "0"
	combo_label.text = "0x"
	$NoteScroller.initialize()
	update_hp_bar()

func update_hp_bar():
	hp = clamp(hp, hp_bar.min_value, hp_bar.max_value)
	bar_tween.interpolate_property(hp_bar, "value", hp_bar.value, hp, .2, Tween.EASE_OUT)
	bar_tween.start()

func enter_climax():
	$NoteScroller.climax = true
	climax = true

	for button in get_tree().get_nodes_in_group("button"):
		button.frame = 2
		button.modulate = Color(2, 2, 2)
		button.get_node("ShineParticles").emitting = true

	for note in get_tree().get_nodes_in_group("visible"):
		note.get_node("AnimatedSprite").frame = 1
		Global.camera.shake(300, .5, 300)
		note.get_node("AnimatedSprite").modulate = Color(2.5, 2.5, 2.5)

	
	lightbulb.get_node("LightbulbSprite").frame = 1
	lightbulb.color = lightbulb_purple
	
func exit_climax():
	$NoteScroller.climax = false
	climax = false

	for button in get_tree().get_nodes_in_group("button"):
		button.frame = 0
		button.modulate = Color(1.5, 1.5, 1.5)
		button.get_node("ShineParticles").emitting = false

	for note in get_tree().get_nodes_in_group("visible"):
		note.get_node("AnimatedSprite").frame = 0
		Global.camera.shake(200, .5, 200)
		note.get_node("AnimatedSprite").modulate = Color(1, 1, 1)

	
	lightbulb.get_node("LightbulbSprite").frame = 0
	lightbulb.color = lightbulb_blue

func add_button(btn_index : int):
	$Buttons/AnimationPlayer.play("add_lane_" + str(btn_index))
	get_parent().get_node("Player").get_node("AnimatedSprite").playing = true

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
