extends ColorRect


func _start():
	visible = true
	$GlitchTimer.start()



func _on_GlitchTimer_timeout():
	visible = false
