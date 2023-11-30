extends Camera2D

@export
var target: CharacterBody2D

func _physics_process(delta):
	position.x = target.position.x
	if target.can_camera_follow:
		position.y = target.position.y
