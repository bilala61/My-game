extends Control

func _ready():
	GameState.reset_game()
	$PlayButton.pressed.connect(_on_play_pressed)
	# Animate title
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($Title, "modulate", Color(1, 0.8, 0.2), 1.0)
	tween.tween_property($Title, "modulate", Color(1, 0.4, 0.6), 1.0)
	tween.tween_property($Title, "modulate", Color(0.4, 0.8, 1.0), 1.0)
	tween.tween_property($Title, "modulate", Color(1, 0.8, 0.2), 1.0)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/deliverymap.tscn")
