extends Control

func _ready():
	set_process_unhandled_input(false)

func _unhandled_input(event):
	if event.is_action_pressed("retry"):
		get_tree().reload_current_scene()
		get_tree().paused = false
