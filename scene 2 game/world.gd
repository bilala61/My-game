extends Node2D


func _on_cliffside_transition_point_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true


func _on_cliffside_transition_point_body_exited(body: Node2D) -> void:
	if body.has_method("play"):
		Global.transition_scene = false 

func change_scene():
	if Global.transition_scene == true:
		if Global.current_scene == "world":
			get_tree().change_scene_to_file("res://scenes.tscn")
			Global.finish_changescenes()
