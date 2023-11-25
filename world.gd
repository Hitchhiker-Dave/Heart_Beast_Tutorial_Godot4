extends Node2D

@export var next_level: PackedScene

var level_time = 0.0
var start_level_msec = 0.0

#accessing specific child nodes via code
@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var start_in = %StartIn
@onready var start_in_label = %StartInLabel
@onready var animation_player = $AnimationPlayer
@onready var level_time_label = %LevelTimeLabel

func _ready():
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "Victory Screen"
		next_level = load("res://Scenes/victory_screen.tscn")
	
	Events.level_completed.connect(show_level_completed) #note: parenthesis not included to avoid function call
	
	#A bunch of shit to handle pausing the game while a countdown plays
	get_tree().paused = true
	start_in.visible = true
	LevelTransition.fade_from_black()
	animation_player.play("countdown")
	await animation_player.animation_finished
	get_tree().paused = false
	start_in.visible = false
	start_level_msec = Time.get_ticks_msec()

func _process(delta):
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text = str(level_time / 1000.0)
	
func retry_level():
	await  LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_file_path)
	
func go_to_next_level():
	if not next_level is PackedScene: return #Check if there is a next level
	
	LevelTransition.fade_to_black() 
	get_tree().change_scene_to_packed(next_level) #use change_scene_to_packed instead of file since level templates are packed scenes
	get_tree().paused =false #Give back player control
	
func show_level_completed():
	level_completed.show() #Toggle level complete screen from invisible to visible
	level_completed.retry_button.grab_focus()
	get_tree().paused =true #Stop game from running

#Next Level and Retry Level Handling
func _on_level_completed_retry():
	retry_level()

func _on_level_completed_next_level():
	go_to_next_level()
