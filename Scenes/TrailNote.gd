extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var point = points[0].y/2
	$Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate()
	$Area2D/CollisionShape2D.shape.resource_local_to_scene = true	
	$Area2D/CollisionShape2D.shape.extents = Vector2(10, point * -1)
	$Area2D/CollisionShape2D.position.y = point
