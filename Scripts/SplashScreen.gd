extends Control


func _ready():
	pass


func _on_SplashScreenPlayer_finished():
	get_tree().change_scene("res://Scenes/Menu.tscn")
	pass
