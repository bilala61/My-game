extends Node

# --------------------------------------------------
# GLOBAL.GD
# This script holds information that ALL scenes need.
# Think of it like a shared notebook for the whole game.
# Because it is an "autoload", it is always available.
# --------------------------------------------------

# The player's total score
var score = 0

# How much money the player has earned
var money = 0

# How many deliveries the player has finished
var deliveries = 0

# Info about the current order being delivered
# We store it as a dictionary (like a labelled box)
var current_order = {}

# A list of all the customers in the game
# Each customer is a dictionary with their details
var customers = [
	{"name": "Kenji",  "x": 200,  "y": 200,  "reward": 50},
	{"name": "Yuki",   "x": 1000, "y": 180,  "reward": 60},
	{"name": "Hana",   "x": 600,  "y": 580,  "reward": 40},
	{"name": "Taro",   "x": 150,  "y": 500,  "reward": 80},
	{"name": "Miko",   "x": 1080, "y": 520,  "reward": 70},
]

# A list of sushi types used in the slice minigame
var sushi_list = [
	{"name": "Tuna Nigiri",  "color": Color(0.9, 0.3, 0.3), "points": 10, "icon": "🍣"},
	{"name": "Salmon Roll",  "color": Color(0.95, 0.55, 0.2),"points": 15, "icon": "🍱"},
	{"name": "Dragon Roll",  "color": Color(0.2, 0.7, 0.3),  "points": 20, "icon": "🥢"},
	{"name": "Shrimp Nigiri","color": Color(0.95, 0.6, 0.5), "points": 12, "icon": "🍤"},
	{"name": "Roe Gunkan",   "color": Color(0.95, 0.7, 0.1), "points": 18, "icon": "🟡"},
]

# A list of danger items the player must NOT slice
var danger_list = [
	{"name": "Wasabi Bomb",  "color": Color(0.2, 0.85, 0.2), "penalty": 30, "icon": "💣"},
	{"name": "Expired Fish", "color": Color(0.6, 0.6, 0.6),  "penalty": 20, "icon": "🐡"},
	{"name": "Hot Pepper",   "color": Color(0.9, 0.1, 0.1),  "penalty": 25, "icon": "🌶"},
]

# Call this to wipe everything back to zero (used at game start)
func reset():
	score     = 0
	money     = 0
	deliveries = 0
	current_order = {}
