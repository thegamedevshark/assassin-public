extends Area2D

enum Direction { LEFT, RIGHT }
@export var direction = Direction.LEFT

@export var speed = 100.0

var bodies = []

func _on_body_entered(body):
	if not body is CharacterBody2D:
		return
	bodies.append(body)
	body.on_conveyor = true
	if direction == Direction.LEFT:
		body.conveyor_speed = -speed
	else:
		body.conveyor_speed = speed

func _on_body_exited(body):
	if not body is CharacterBody2D:
		return
	bodies.erase(body)
	body.on_conveyor = false
