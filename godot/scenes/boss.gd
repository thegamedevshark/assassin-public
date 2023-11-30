extends CharacterBody2D

func die():
	$AnimationPlayer.play("dead")

func next():
	print("LOAD END!")
	get_tree().change_scene_to_file("res://color_rect.tscn")
