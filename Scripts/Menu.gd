extends Control

onready var animationPlayer : AnimationPlayer = $AnimationPlayer

func _ready():
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("start") and animationPlayer.current_animation != "Start":
		$SFXPlayer.play(0)
		animationPlayer.play("Start")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Start":
		get_tree().change_scene("res://Scenes/Menu.tscn")
	pass
