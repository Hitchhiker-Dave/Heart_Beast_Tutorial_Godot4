extends Node2D

#accessing specific child nodes via code
@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	Events.level_completed.connect(show_level_completed) #note: parenthesis not included to avoid function call
	
func show_level_completed():
	level_completed.show() #Toggle level complete screen from invisible to visible
	get_tree().paused =true #Stop game from running
