extends AnimatedSprite

var perfect = false
var good = false
var okay = false
var current_note = null
var long_note
var trail_node
var trail = false
var particles

onready var default_scale = scale
var scale_factor = 1.15

export var input = ""

export (Color, RGB) var gray

onready var rhythm_controller = get_node("/root/MainScene/Rhythm")

func _unhandled_input(event):
	if !is_in_group("button"):
		return
	
	if event.is_action(input):
		if event.is_action_pressed(input, false):
			if current_note != null:
				
				if (perfect || good || okay):
					rhythm_controller.increase_hp()
				
				if trail:
					print("keep holding")
					long_note.destroy(3)
					current_note = null
				
				if current_note != null:
					if perfect:
						rhythm_controller.increment_score(3)
						current_note.destroy(3)
					elif good:
						rhythm_controller.increment_score(2)
						current_note.destroy(2)
					elif okay:
						rhythm_controller.increment_score(1)
						current_note.destroy(1)
					reset()
				
			elif trail:
				miss_long_note()
			else:
				rhythm_controller.increment_score(0)
		if event.is_action_pressed(input):
			scale = scale * scale_factor
			if(rhythm_controller.climax):
				frame = 3
			else:
				frame = 1
		elif event.is_action_released(input):
			if trail:
#				if particles:
#					particles.emitting = false
				miss_long_note()
#
			$PushTimer.start()


func _on_PerfectArea_area_entered(area):
	if area.is_in_group("note"):
		perfect = true
#		area.destroy(0)


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
		
	if area.is_in_group("trail"):
		print("entered")
		trail_node = area.get_parent()
		long_note = trail_node.get_node("Note")
		trail = true


func _on_OkayArea_area_exited(area):
	if area.is_in_group("note"):
		okay = false
		current_note = null
		
	if area.is_in_group("trail"):
		if !trail: return
		
		trail = false
		
		if Input.is_action_pressed(input):
			print("u did it")
			if(particles):
				particles.emitting = false
			rhythm_controller.increment_score(3)


func _on_PushTimer_timeout():
	scale = default_scale

	if rhythm_controller.climax:
		frame = 2
	else:
		frame = 0

func reparent_long_note():
	trail_node.remove_child(long_note)
	add_child(long_note)
	long_note.set_owner(self)
	long_note.get_node("AnimatedSprite").scale = Vector2.ONE
	
	long_note.global_position = global_position
	
func change_particles():
	particles.one_shot = !particles.one_shot
	if(particles.explosiveness == 1):
		particles.explosiveness = 0
	else:
		particles.explosiveness = 1
	particles.emitting = !particles.emitting

func miss_long_note():
	trail = false
	rhythm_controller.miss(rhythm_controller.miss_damage)
	trail_node.default_color = gray

func reset():
	current_note = null
	perfect = false
	good = false
	okay = false
