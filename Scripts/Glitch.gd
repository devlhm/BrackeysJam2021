extends ColorRect


func start():
	visible = true
	$GlitchTimer.start()

func end():
	visible = false
	$GlitchTimer.stop()

func _on_GlitchTimer_timeout():
	visible = false
