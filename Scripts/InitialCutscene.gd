extends Node

onready var cutscene: Control = $Cutscene

func _ready():
	cutscene.datas = [
		{"sprite": "res://Sprites/Cutscenes/Initial/a0000.png", "text": "I mean... PUNK... MY NEIGHBOURS!"},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0001.png", "text": "Hello World"},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0002.png", "text": "Hello World"},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0003.png", "text": "Hello World"},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0004.png", "text": "Hello World"},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0005.png", "text": "Hello World"},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0006.png", "text": "Hello World"},
		{"sprite": "res://Sprites/Cutscenes/Initial/a0007.png", "text": "Hello World"},
	]
	cutscene.sceneOnFinish = "res://Scenes/Menu.tscn"
	cutscene.start(0)
