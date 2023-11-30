extends CanvasLayer

@export var goal: Goal
@export var music: AudioStreamPlayer

func _ready():
	visible = true
	$AnimationPlayer.play("fade_in")
	goal.connect("reached", fade_out)
	
func fade_out():
	$AnimationPlayer.play_backwards("fade_in")
	if music != null:
		music.fade_out()
	await $AnimationPlayer.animation_finished
	goal.next()
