extends Control

var actionToChange = ""
var buttonPressed: Button

onready var backButton: Button = $VBox/Center/BackButton
onready var SFXPlayer: AudioStreamPlayer = $SFXPlayer

onready var button1: Button = $VBox/CenterControls/ColorRect/CenterContainer/ChangeKeyContainer/button1
onready var button2: Button = $VBox/CenterControls/ColorRect/CenterContainer/ChangeKeyContainer/button2
onready var button3: Button = $VBox/CenterControls/ColorRect/CenterContainer/ChangeKeyContainer/button3
onready var button4: Button = $VBox/CenterControls/ColorRect/CenterContainer/ChangeKeyContainer/button4
onready var button5: Button = $VBox/CenterControls/ColorRect/CenterContainer/ChangeKeyContainer/button5
onready var supress: Button = $VBox/CenterControls/ColorRect/CenterContainer/ChangeKeyContainer/supress

onready var changeKeyContainer: GridContainer = $VBox/CenterControls/ColorRect/CenterContainer/ChangeKeyContainer

func _ready():
	$"/root/MusicPlayer".change_music("Stop", 0)
	button1.text = OS.get_scancode_string(InputMap.get_action_list("button1")[0].get_scancode())
	button2.text = OS.get_scancode_string(InputMap.get_action_list("button2")[0].get_scancode())
	button3.text = OS.get_scancode_string(InputMap.get_action_list("button3")[0].get_scancode())
	button4.text = OS.get_scancode_string(InputMap.get_action_list("button4")[0].get_scancode())
	button5.text = OS.get_scancode_string(InputMap.get_action_list("button5")[0].get_scancode())
	supress.text = OS.get_scancode_string(InputMap.get_action_list("supress")[0].get_scancode())
	pass

func _unhandled_key_input(event):
	if event is InputEventKey and actionToChange != "":
		changeButton(actionToChange, event.scancode)
		actionToChange = ""
		buttonPressed.pressed = false

func _on_ChangeKeyButton_pressed(key):
	actionToChange = key
	buttonPressed = changeKeyContainer.get_node(key)
	
func changeButton(action, scancode):
	InputMap.get_action_list(action)[0].set_scancode(scancode)
	buttonPressed.text = OS.get_scancode_string(scancode)


func _on_BackButton_pressed():
	playSFX("selected")
	OS.delay_msec(175)
	get_tree().change_scene("res://Scenes/OptionsMenu.tscn")
	pass


func _on_BackButton_mouse_entered():
	playSFX("entered")
	backButton.get_font("font").size = 80
	pass


func _on_BackButton_mouse_exited():
	backButton.get_font("font").size = 64
	pass

func playSFX(stream: String):
	SFXPlayer.stop()
	if stream == "selected":
		SFXPlayer.set_stream(load("res://Sounds/selected.ogg"))
	elif stream == "entered":	
		SFXPlayer.set_stream(load("res://Sounds/mouseEntered.ogg"))
	SFXPlayer.play(0)
