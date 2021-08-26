extends Node2D

export var visit_interval : float = 12
export (int, 0, 30) var visit_chance = 30
export var visit_duration : float = 5
export (float, 0) var stop_threshold = 1
export (float, 0) var resume_threshold = .8

var time_since_check : float = 0
var time_since_visit : float = 0
var time_visiting: float = 0
var rng = RandomNumberGenerator.new()
var visiting := false

func _ready():
	
	set_process(false)

func start():
	print("neighbor start")
	set_process(true)
	
func _process(delta):
	
	if !visiting:
		time_since_check += delta
		if(time_since_check >= visit_interval):
			time_since_check = 0
			rng.randomize()
			var rand = rng.randi_range(0, 100)
			if (rand < visit_chance):
				time_since_visit = 0
				toggle_visit()
		else:
			if(get_parent().supressing && time_since_visit > resume_threshold):
				get_parent().miss(.2)
				
	else:
		time_visiting += delta
		
		if(get_parent().supressing):
			if time_visiting >= stop_threshold:
				set_process(false)
				get_parent().get_node("GameOverLayer").get_child(0).start()
			else:
				return
				
		if time_visiting >= visit_duration:
			time_visiting = 0
			toggle_visit()
		
func toggle_visit():
	$NeighborIndicator.visible = !$NeighborIndicator.visible
	visiting = !visiting
	
func end():
	print("neighbor end")
	set_process(false)
