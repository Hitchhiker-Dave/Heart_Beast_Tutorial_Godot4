extends CenterContainer

func _ready():
	LevelTransition.fade_from_black()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
