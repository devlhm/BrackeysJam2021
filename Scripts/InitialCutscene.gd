extends Node

onready var cutscene: Control = $Cutscene

func _ready():
	cutscene.datas = [
		{"sprite": "res://Sprites/Cutscenes/Initial/a0000.png", "text": "It was a normal day..."},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0001.png", "text": "Until the rent arrears..."},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0002.png", "text": "had arrived."},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0003.png", "text": ""},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0004.png", "text": "But what he hadn't expected..."},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0005.png", "text": "Was a 99% tax fee."},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0006.png", "text": "And so..."},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0007.png", "text": "He's gonna have to say his good-fashioned farewell."}
	]
	cutscene.sceneOnFinish = "res://Scenes/Menu.tscn"
	cutscene.start(0)
	
func _process(delta):
	if Input.is_action_just_pressed("skipCutscene"):
		get_tree().change_scene(cutscene.sceneOnFinish)
