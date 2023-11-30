extends Area2D

@export var note_interface: CanvasLayer
@export_multiline var text: String

@onready var label: Label = $Label

var interacting: bool = false

func _ready():
	note_interface.connect("close", _on_close)
	
	$AnimationPlayer.play("bob")#
	label.visible = false

func _process(delta):
	if label.visible:
		if Input.is_action_just_pressed("interact"):
			get_tree().paused = true
			interacting = true
			note_interface.visible = true
			note_interface.set_text(text)

func _on_body_entered(body):
	label.visible = true

func _on_body_exited(body):
	label.visible = false

func _on_close():
	get_tree().paused = false
	interacting = false
	note_interface.visible = false
