extends Control


func _on_button_pressed() -> void:
	print ("START button pressed")
	get_tree().change_scene_to_file("res://delivery_map.tscn")



func _on_button_2_pressed() -> void:
	print ("EXIT button pressed")
	get_tree().quit()
