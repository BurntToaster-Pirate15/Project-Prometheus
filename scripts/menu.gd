extends MarginContainer



func _on_button_play_new_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_button_exit_pressed():
	get_tree().quit()
