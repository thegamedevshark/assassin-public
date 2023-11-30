extends Area2D

var bars = []

func _on_area_entered(area):
	bars.append(area)

func _on_area_exited(area):
	bars.erase(area)
