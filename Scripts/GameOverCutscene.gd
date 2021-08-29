extends Node

onready var retryButton: Button = $Cutscene/Margin2/VBox/HBox/RetryButton
onready var quitButton: Button = $Cutscene/Margin2/VBox/HBox/QuitButton

onready var SFXPlayer: AudioStreamPlayer = $SFXPlayer

onready var cutscene: Control = $Cutscene

func _ready():
	cutscene.datas = [
		{"sprite": "res://Sprites/Cutscenes/GameOver/gameOver.png", "text": "Not enough chaos. Game Over"}
	]
	cutscene.sceneOnFinish = ""
	cutscene.start(0)
	pass
	
func _on_Button_pressed(button):
	playSFX("selected")
	if button == "Retry":
		get_tree().change_scene("res://Scenes/MainScene.tscn")
	elif button == "Quit":
		get_tree().change_scene("res://Scenes/Menu.tscn")
	pass

func _on_Button_mouse_entered(button):
	playSFX("entered")
	if button == "Retry":
		retryButton.get_font("font").size = 80
	elif button == "Quit":
		quitButton.get_font("font").size = 80
		
func playSFX(stream: String):
	SFXPlayer.stop()
	if stream == "selected":
		SFXPlayer.set_stream(load("res://Sounds/selected.ogg"))
	elif stream == "entered":	
		SFXPlayer.set_stream(load("res://Sounds/mouseEntered.ogg"))
	SFXPlayer.play(0)


func _on_Button_mouse_exited():
	retryButton.get_font("font").size = 64
	quitButton.get_font("font").size = 64
	pass
