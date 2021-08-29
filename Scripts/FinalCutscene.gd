extends Node

onready var cutscene: Control = $Cutscene

func _ready():
	cutscene.datas = [
		{"sprite": "res://Sprites/Cutscenes/Final/a0000.png", "text": 'Dollyn: "Job well done, time to leave this place."'},
		{"sprite": "res://Sprites/Cutscenes/Final/a0001.png", "text": "However, he was caught by surprise when..."},
		{"sprite": "res://Sprites/Cutscenes/Final/a0002.png", "text": 'Ademir: "Where do you think you are going?"'},
		{"sprite": "res://Sprites/Cutscenes/Final/a0003.png", "text": "..."},
		{"sprite": "res://Sprites/Cutscenes/Final/a0004.png", "text": "The show must go on."},
		{"sprite": "res://Sprites/Cutscenes/Final/a0005.png", "text": "And with chaos at hand, let's rock!  I mean... PUNK... MY NEIGHBORS!"}
	]
	cutscene.sceneOnFinish = "res://Scenes/CreditsScreen.tscn"
	cutscene.start(0)
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("skipCutscene"):
		get_tree().change_scene(cutscene.sceneOnFinish)
