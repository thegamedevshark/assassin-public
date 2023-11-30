extends Area2D

@export var nodes: Array[Node]

func _ready():
	make_all_visible(false)

func make_all_visible(value: bool):
	for n in self.nodes:
		n.visible = value
		
func _on_body_entered(body):
	make_all_visible(true)


func _on_body_exited(body):
	make_all_visible(false)
