extends Control

onready var buttonsContainer: VBoxContainer = $Center/Buttons
onready var SFXPlayer: AudioStreamPlayer = $SFXPlayer

func _ready():
	$"/root/MusicPlayer".change_music("res://Sounds/Menu.ogg", -1)
	pass

func _on_Button_pressed(button):
	playSFX("selected")
	OS.delay_msec(175)
	if button == "Start":
		get_tree().change_scene("res://Scenes/MainScene.tscn")
		$"/root/MusicPlayer".change_music("Stop", 0)
	elif button == "Options":
		get_tree().change_scene("res://Scenes/OptionsMenu.tscn")
	elif button == "Credits":
		$"/root/MusicPlayer".change_music("Stop", 0)
		get_tree().change_scene("res://Scenes/CreditsScreen.tscn")
		pass
	elif button == "Quit":
		$"/root/MusicPlayer".change_music("Stop", 0)
		get_tree().quit()
	
func _on_Button_mouse_entered(button):
	playSFX("entered")
	if button == "Start":
		buttonsContainer.get_node(button).get_font("font").size = 64
	elif button == "Options":
		buttonsContainer.get_node(button).get_font("font").size = 64
	elif button == "Credits":
		buttonsContainer.get_node(button).get_font("font").size = 64
	elif button == "Quit":
		buttonsContainer.get_node(button).get_font("font").size = 64
	
func _on_Button_mouse_exited():
	for button in buttonsContainer.get_children():
		button.get_font("font").size = 48
	
func playSFX(stream: String):
	SFXPlayer.stop()
	if stream == "selected":
		SFXPlayer.set_stream(load("res://Sounds/selected.ogg"))
	elif stream == "entered":	
		SFXPlayer.set_stream(load("res://Sounds/mouseEntered.ogg"))
	SFXPlayer.play(0)
