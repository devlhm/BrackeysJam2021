extends AnimatedSprite

var perfect = false
var good = false
var okay = false
var current_note = null

onready var default_scale = scale
export (float, 1) var scale_factor = 1.1

export var input = ""

onready var rhythm_controller = get_node("/root/MainScene/Rhythm")


func _unhandled_input(event):
	if !is_in_group("button"):
		return
	
	if event.is_action(input):
		if event.is_action_pressed(input, false):
			if current_note != null:
				
				if (perfect || good || okay):
					rhythm_controller.increase_hp()
				
				if perfect:
					rhythm_controller.increment_score(3)
					current_note.destroy(3)
				elif good:
					rhythm_controller.increment_score(2)
					current_note.destroy(2)
				elif okay:
					rhythm_controller.increment_score(1)
					current_note.destroy(1)
				_reset()
			else:
					rhythm_controller.increment_score(0)
		if event.is_action_pressed(input):
				scale = scale * scale_factor
		elif event.is_action_released(input):
			$PushTimer.start()


func _on_PerfectArea_area_entered(area):
	if area.is_in_group("note"):
		perfect = true


func _on_PerfectArea_area_exited(area):
	if area.is_in_group("note"):
		perfect = false


func _on_GoodArea_area_entered(area):
	if area.is_in_group("note"):
		good = true


func _on_GoodArea_area_exited(area):
	if area.is_in_group("note"):
		good = false


func _on_OkayArea_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		current_note = area


func _on_OkayArea_area_exited(area):
	if area.is_in_group("note"):
		okay = false
		current_note = null


func _on_PushTimer_timeout():
		scale = default_scale


func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false
