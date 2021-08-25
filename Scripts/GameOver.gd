extends Control

func _ready():
	set_process_unhandled_input(false)

func _unhandled_input(event):
	if event.is_action_pressed("retry"):
		get_tree().paused = false
		get_tree().reload_current_scene()

func start():
	var tween = get_parent().get_node("Tween")
	
	tween.interpolate_property(self, "rect_position", Vector2(0, rect_position.y), Vector2.ZERO, .2)
	AudioServer.remove_bus_effect(2, 0)
	tween.start()
	set_process_unhandled_input(true)
	get_tree().paused = true
