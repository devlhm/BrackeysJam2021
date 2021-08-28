extends Area2D

var hit = false
var to_destroy
var destroy_limit = 800

func _process(delta):
	if global_position.y > destroy_limit && !to_destroy && !hit:
		to_destroy = true
		$Timer.start()
		var rhythm_controller = get_node("/root/MainScene/Rhythm")
		rhythm_controller.miss(rhythm_controller.miss_damage)

func reparent_particles():
	var particles = $Particles2D
	var prev_global_position = particles.global_position
	remove_child(particles)
	get_parent().get_parent().add_child(particles)
	particles.global_position = prev_global_position
	particles.set_owner(get_parent().get_parent())
	
	return particles

func destroy(score):
	hit = true
	if (score != -1):
		reparent_particles().emitting = true
	$AnimatedSprite.visible = false
#	$Trail.visible = false
	queue_free()
	if score == 3:
		$Node2D/Label.text = "GREAT"
		$Node2D/Label.modulate = Color("f6d6bd")
	elif score == 2:
		$Node2D/Label.text = "GOOD"
		$Node2D/Label.modulate = Color("c3a38a")
	elif score == 1:
		$Node2D/Label.text = "OKAY"
		$Node2D/Label.modulate = Color("997577")

func _on_Timer_timeout():
	queue_free()
