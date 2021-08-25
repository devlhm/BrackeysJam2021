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

var songs = [FirstSong]
var song_index = 0

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
export var transparency_amount : float = 0.6
var default_alpha
var default_overlay_alpha
export var default_shader_scale = 1.1
export var shader_reduction = .7
var default_light_energy
export var light_intense = 1.7

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

var colors = ["Green", "Blue", "Red", "Yellow", "Pink"]

export (NodePath) var tv_screen_path
var tv_screen
export (float) var miss_damage = 3

func _ready():
	randomize()
	for button in get_tree().get_nodes_in_group("button"):
		lanes.append(Vector2(button.position.x, SPAWN_Y))
	lane_amount = lanes.size()
	$Conductor.play_with_beat_offset(8)
	vignette.get_material().set("shader_param/SCALE", 1.1)
	tv_screen = get_node(tv_screen_path)
	lightbulb = get_parent().get_node("Lightbulb")
	lightbulb_tween = lightbulb.get_node("Tween")
	default_light_energy = lightbulb.energy
	
	default_alpha = modulate.a
	default_overlay_alpha = overlay.modulate.a
	pattern_beats = FirstSong.notes.keys()
	bpm = FirstSong.bpm
	for i in range(1, 9):
		missSFX.append(load("res://Sounds/miss" + str(i) + ".ogg"))
		
func _process(delta):
	if !$Neighbor.visiting && supressing:
		miss(.2)
		
	if $Neighbor.visiting && tv_screen.animation != "skull":
		tv_screen.animation = "skull"
	elif !$Neighbor.visiting && tv_screen.animation != "default":
		tv_screen.animation = "default"


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
		
		

func _on_Conductor_beat(position_beats, position_measure):
	if position_beats == songs[song_index].song_start:
		song_started = true
	
	if song_started:
		if position_measure != 4:
			Global.camera.zoom_cam(.002, .05)
		else:
			Global.camera.zoom_cam(.003, .06)
			
		if !supressing:
			lightbulb.energy = light_intense
		
		lightbulb_tween.interpolate_property(lightbulb, "energy", lightbulb.energy, default_light_energy, .5, Tween.EASE_OUT)
		lightbulb_tween.start()
	
	
	print("measure: " + str(position_measure))
	print("beat: " + str(position_beats))
	
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
	
func miss(damage):
	combo = 0
	$Combo.text = ""
	
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
	

func update_hp_bar():
	hp = clamp(hp, hp_bar.min_value, hp_bar.max_value)
	bar_tween.interpolate_property(hp_bar, "value", hp_bar.value, hp, .5, Tween.EASE_OUT)
	bar_tween.start()

func enter_climax():
	climax = true
	
	for button in get_tree().get_nodes_in_group("button"):
		button.frame = 2
		
	for note in get_tree().get_nodes_in_group("note"):
		note.get_node("AnimatedSprite").frame = 1
