extends LightOccluder2D

@export var collision_polygon: CollisionPolygon2D

func _ready():
	occluder.polygon = collision_polygon.polygon
