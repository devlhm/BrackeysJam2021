extends Node2D

export var visit_interval : float = 12
export var visit_chance : int = 30
export var visit_duration : float = 5
export var stop_threshold : float = 1

var time_since_check : float = 0
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
			rng.randomize()
			var rand = rng.randi_range(0, 100)
			if (rand < visit_chance):
				time_since_check = 0
				toggle_visit()
	else:
		time_visiting += delta
		
		if(!Input.is_action_pressed("supress")):
			if time_visiting >= stop_threshold:
				set_process(false)
				get_parent().get_node("GameOverLayer").get_child(0).start()
			else:
				pass
				
		if time_visiting >= visit_duration:
			time_visiting = 0
			toggle_visit()
		
func toggle_visit():
	$NeighborIndicator.visible = !$NeighborIndicator.visible
	visiting = !visiting
	
func end():
	print("neighbor end")
	set_process(false)
