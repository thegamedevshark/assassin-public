extends Area2D
class_name Goal

@export var next_level: PackedScene

signal reached

func _on_body_entered(body):
	emit_signal("reached")

func next():
	get_tree().change_scene_to_packed(next_level)
