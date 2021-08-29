extends Node2D

func transit():
	$AnimationPlayer.play("transit")
	
func transit_back():
	$AnimationPlayer.play("transit_back")
