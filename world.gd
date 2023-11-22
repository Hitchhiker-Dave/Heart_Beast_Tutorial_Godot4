extends Node2D

@export var next_level: PackedScene

#accessing specific child nodes via code
@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	Events.level_completed.connect(show_level_completed) #note: parenthesis not included to avoid function call
	
func show_level_completed():
	level_completed.show() #Toggle level complete screen from invisible to visible
	get_tree().paused =true #Stop game from running
	await get_tree().create_timer(0.5).timeout #Create independent timer so the next level transistion pauses for a moment
	
	#Move to next level
	if not next_level is PackedScene: return #Check if there is a next level
	
	await LevelTransition.fade_to_black() 
	get_tree().change_scene_to_packed(next_level) #use change_scene_to_packed instead of file since level templates are packed scenes
	get_tree().paused =false #Give back player control
	await LevelTransition.fade_from_black()
