extends Control

func _ready():
	pass



func _on_Button_pressed(button):
	if button == "Start":
		get_tree().change_scene("res://Scenes/MainScene.tscn")
	elif button == "Options":
		get_tree().change_scene("res://Scenes/OptionsMenu.tscn")
	elif button == "Credits":
		pass
	elif button == "Quit":
		get_tree().quit()
	pass

