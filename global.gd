extends Node

var player_current_attack = false

var current_scene = "word"
var transition_scene = false

var player_exit_cliffside_posx = 0
var player_exit_cliffside_posy = 0
var player_start_posx = 21
var player_start_posy = 67

func finish_changescenes():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "scenes"
		else:
			current_scene = "world"
