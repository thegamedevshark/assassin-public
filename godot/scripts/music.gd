extends AudioStreamPlayer

func _ready():
	$AnimationPlayer.play("fade_in")

func fade_out():
	$AnimationPlayer.play_backwards("fade_in")
