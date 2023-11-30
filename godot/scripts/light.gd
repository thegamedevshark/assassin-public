extends Area2D

@export var collision_polygon: CollisionPolygon2D
@export var do_timer: bool = false
@export var start_on = true
@export var time_on: float = 1
@export var time_off: float = 1

@onready var timer = $Timer

func _ready():
	if not start_on:
		start_on = false
	
	if do_timer:
		if start_on:
			print("START")
			timer.start(time_on)
		else:
			timer.start(time_off)
	
	var occ = OccluderPolygon2D.new()
	occ.polygon = collision_polygon.polygon
	$LightOccluder2D.occluder = occ

func _on_body_entered(body):
	pass
	# body.light_areas_inside.append(self)
		
func _on_body_exited(body):
	pass
	# body.light_areas_inside.erase(self)

func _on_timer_timeout():
	start_on = !start_on
	if start_on:
		visible = true
		timer.start(time_on)
		collision_polygon.disabled = false
	else:
		visible = false
		timer.start(time_off)
		collision_polygon.disabled = true
