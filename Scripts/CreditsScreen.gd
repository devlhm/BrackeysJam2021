extends Control


func _ready():
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("skipCutscene"):
		get_tree().change_scene("res://Scenes/Menu.tscn")

func _on_VideoPlayer_finished():
	get_tree().change_scene("res://Scenes/Menu.tscn")
	pass
