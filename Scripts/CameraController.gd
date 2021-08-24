extends Camera2D

onready var tween := $Tween
onready var shake_timer := $ShakeTimer
onready var zoom_timer := $ZoomTimer

var shake_amount = 0
var zoom_amount = 0

var to_shake : bool
var to_zoom : bool
var default_offset = offset
var default_zoom = zoom

func _ready():
	Global.camera = self
	print(default_zoom)

func _process(delta):
	
	if to_shake:
		offset = Vector2(rand_range(-shake_amount, shake_amount), rand_range(shake_amount, -shake_amount)) * delta + default_offset
	if to_zoom:
		zoom -= Vector2(zoom_amount, zoom_amount)
		offset -= Vector2(zoom_amount, zoom_amount)
		rotation_degrees = rand_range(-zoom_amount * 190, zoom_amount * 190)
	

func shake(new_shake, shake_time=0.4, shake_limit=100):
	shake_amount += new_shake
	
	if shake_amount > shake_limit:
		shake_amount = shake_limit
		
	shake_timer.wait_time = shake_time
	
	tween.stop_all()
	to_shake = true
	shake_timer.start()
	
func zoom_cam(new_zoom, zoom_time=0.4):
	zoom_amount = new_zoom
		
	zoom_timer.wait_time = zoom_time
	
	tween.stop_all()
	to_zoom = true
	zoom_timer.start()

func _on_ShakeTimer_timeout():
	shake_amount = 0
	
	tween.interpolate_property(self, "offset", offset, default_offset, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	to_shake = false
	tween.start()


func _on_ZoomTimer_timeout():
	
	tween.interpolate_property(self, "zoom", zoom, default_zoom, 0.05, Tween.EASE_OUT)
	tween.interpolate_property(self, "offset", offset, default_offset, 0.05, Tween.EASE_OUT)
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, 0, 0.05, Tween.EASE_OUT)
	to_zoom = false
	tween.start()
