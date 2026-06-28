extends Control

# --------------------------------------------------
# MAINMENU.GD
# This script runs the title screen.
# All it does is reset the game and wait for a button press.
# --------------------------------------------------

func _ready():
	# Reset all scores back to zero when the menu loads
	Global.reset()

	# Connect the button so pressing it calls our function below
	$StartButton.pressed.connect(start_game)

	# Make the title slowly cycle through rainbow colours
	rainbow_title()

func start_game():
	# Change to the delivery map scene
	get_tree().change_scene_to_file("res://scenes/DeliveryMap.tscn")

func rainbow_title():
	# A tween smoothly changes a value over time
	var tween = create_tween()
	tween.set_loops()  # loop forever
	tween.tween_property($Title, "modulate", Color(1, 0.6, 0.1), 1.0)
	tween.tween_property($Title, "modulate", Color(0.4, 1.0, 0.5), 1.0)
	tween.tween_property($Title, "modulate", Color(0.4, 0.7, 1.0), 1.0)
	tween.tween_property($Title, "modulate", Color(1, 0.4, 0.8), 1.0)
