extends PointLight2D

var do_colors: bool = false

var colors: Array[Color] = [
	Color(1, 0, 1),
	Color(1, 0, 0),
	Color(0, 0, 1),
	Color(1, 1, 0),
	Color(0, 1, 0),
]

func _ready():
	if do_colors:
		change()

func change():
	var prev = color
	while color == prev:
		color = colors.pick_random()

func _on_timer_timeout():
	if do_colors:
		change()
