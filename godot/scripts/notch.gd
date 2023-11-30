extends Marker2D
class_name Notch

enum Access { WALK }
@export
var access = Access.WALK

@export
var pause = 1
@onready
var pause_timer = $PauseTimer
