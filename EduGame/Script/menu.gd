extends Control



func _on_play_pressed():
	pass # Replace with function body.
	# get_tree().change_scene_to_file([---ADD_PATH---])


func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")



func _on_quit_pressed():
	get_tree().quit()
