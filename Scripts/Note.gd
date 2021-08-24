extends Area2D

var speed = 0
var hit = false


func _ready():
	pass


func _physics_process(delta):
	if !hit:
		global_position.y += speed * delta
		if position.y > 750:
			queue_free()
			get_parent().miss()
	else:
		$Node2D.position.y -= speed * delta


func initialize(lane, lane_index, dist_to_target, climax):
	var frame = lane_index
	if climax:
		frame += 5
	
	global_position = lane
	speed = dist_to_target / 2.0
	$AnimatedSprite.frame = frame


func destroy(score):
	$Particles2D.emitting = true
	$AnimatedSprite.visible = false
	$Timer.start()
	hit = true
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
