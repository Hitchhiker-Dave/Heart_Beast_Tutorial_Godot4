extends Node2D

#accessing specific child nodes via code
@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon2d = $StaticBody2D/CollisionPolygon2D/Polygon2D

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK) #set background to black (doesn't effect foreground)
	polygon2d.polygon = collision_polygon_2d.polygon
	
func _process(_delta):
	pass
