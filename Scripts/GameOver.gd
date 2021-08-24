extends Control

func _ready():
	set_process_unhandled_input(false)

func _unhandled_input(event):
	if event.is_action_pressed("retry"):
		get_tree().reload_current_scene()
		get_tree().paused = false

func start():
	var tween = get_parent().get_node("Tween")
	
	tween.interpolate_property(self, "rect_position", Vector2(0, rect_position.y), Vector2.ZERO, 1)
	tween.start()
	set_process_unhandled_input(true)
	get_tree().paused = true
