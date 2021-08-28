extends AudioStreamPlayer2D

var missSFX = []
var footstepsSFX = load("res://Sounds/Footsteps.ogg")
var bellSFX = load("res://Sounds/bell.ogg")
var evo1 = load("res://Sounds/Evo1.ogg")
var evo2 = load("res://Sounds/Evo2.ogg")

func _ready():
	for i in range(1, 9):
		missSFX.append(load("res://Sounds/miss" + str(i) + ".ogg"))

func play_miss():
	volume_db = 0
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	stream = missSFX[rng.randi_range(0,7)]
	play()

func play_bell():
	stream = bellSFX
	volume_db = 0
	play()

func play_footsteps():
	stream = footstepsSFX
	volume_db = 15
	play()

func play_evolution_1():
	volume_db = 0
	stream = evo1
	play()

func play_evolution_2():
	volume_db = 0
	stream = evo2
	play()
