extends MarginContainer



func _on_button_play_new_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
