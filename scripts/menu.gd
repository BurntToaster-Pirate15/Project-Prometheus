extends MarginContainer



func _on_button_play_new_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/Level_00_Template.tscn")


func _on_button_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_button_exit_pressed():
	get_tree().quit()


