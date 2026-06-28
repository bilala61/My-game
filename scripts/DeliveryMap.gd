extends Node2D

# --------------------------------------------------
# DELIVERYMAP.GD
# This is the overworld where you drive around.
#
# The game loop is simple:
#   1. Drive to the Restaurant  --> picks up an order
#   2. Drive to the customer    --> starts the slice mini-game
#   3. Repeat!
# --------------------------------------------------

# How fast the player moves (pixels per second)
const SPEED = 220.0

# How close you need to be to "arrive" somewhere
const ARRIVE_DISTANCE = 75.0

# The restaurant sits in the middle of the screen
const RESTAURANT_X = 640.0
const RESTAURANT_Y = 360.0

# We track whether the player currently has an order or not
var has_order = false

# Which customer are we delivering to? (index into Global.customers)
var target_customer = 0

# ---- Called once when the scene first loads ----
func _ready():
	draw_roads()
	spawn_customers()
	update_hud()

# ---- Called every frame ----
func _process(delta):
	move_player(delta)
	check_arrival()
	update_hud()

# ---- Move the scooter with keyboard input ----
func move_player(delta):
	# Build a direction vector from which keys are held
	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Normalise so diagonal movement isn't faster
	if direction.length() > 0:
		direction = direction.normalized()

	# Set the velocity and let Godot move the body
	$Player.velocity = direction * SPEED
	$Player.move_and_slide()

	# Flip the scooter emoji when going left
	if direction.x < 0:
		$Player/Icon.scale.x = -1
	elif direction.x > 0:
		$Player/Icon.scale.x = 1

# ---- Check if the player has arrived somewhere ----
func check_arrival():
	var player_pos = $Player.position

	# --- Case 1: player does NOT have an order ---
	# Check if they reached the restaurant
	if has_order == false:
		var restaurant_pos = Vector2(RESTAURANT_X, RESTAURANT_Y)
		if player_pos.distance_to(restaurant_pos) < ARRIVE_DISTANCE:
			pick_up_order()

	# --- Case 2: player HAS an order ---
	# Check if they reached the target customer's house
	else:
		var customer = Global.customers[target_customer]
		var customer_pos = Vector2(customer.x, customer.y)
		if player_pos.distance_to(customer_pos) < ARRIVE_DISTANCE:
			# Go to the slice mini-game!
			get_tree().change_scene_to_file("res://scenes/SliceGame.tscn")

# ---- Give the player a random order ----
func pick_up_order():
	# Only pick up if we don't already have one
	if has_order:
		return

	has_order = true

	# Pick a random customer to deliver to
	target_customer = randi() % Global.customers.size()
	var customer = Global.customers[target_customer]

	# Build a random list of sushi items for the order
	var item_count = randi_range(2, 5)
	var items = []
	for i in item_count:
		var random_sushi = Global.sushi_list[randi() % Global.sushi_list.size()]
		items.append(random_sushi.name)

	# Save the order in Global so SliceGame can read it
	Global.current_order = {
		"customer" : customer.name,
		"items"    : items,
		"reward"   : customer.reward,
	}

	# Show the order box in the corner
	$HUD/OrderBox.visible = true

	# Highlight the target customer's house yellow
	var house = $CustomerLayer.get_child(target_customer)
	house.get_child(0).color = Color(1, 0.85, 0.1)  # the ColorRect behind the house

	show_popup("ORDER PICKED UP! 🍱", Color(0.3, 1, 0.4))
	show_status("Now deliver to " + customer.name + "! 🏠")

# ---- Update all the labels in the top-left corner ----
func update_hud():
	$HUD/ScoreLabel.text    = "⭐ Score: "      + str(Global.score)
	$HUD/MoneyLabel.text    = "💰 Money: $"    + str(Global.money)
	$HUD/DeliveryLabel.text = "📦 Deliveries: " + str(Global.deliveries)

	# Update the order box text
	if has_order and Global.current_order.size() > 0:
		var order = Global.current_order
		var text  = "Deliver to: " + order.customer + "\n"
		text     += "Items: " + ", ".join(order.items) + "\n"
		text     += "Reward: $" + str(order.reward)
		$HUD/OrderBox/OrderLabel.text = text
	else:
		$HUD/OrderBox/OrderLabel.text = "No order yet"
		$HUD/OrderBox.visible = false
		show_status("Drive to the 🏯 Restaurant to get an order!")

# ---- Show a small message at the top-centre ----
func show_status(message):
	$HUD/StatusLabel.text = message

# ---- Show a big floating popup in the middle of the screen ----
func show_popup(message, colour):
	var label = $HUD/PopupLabel
	label.text     = message
	label.modulate = colour
	# Fade it out over 1.5 seconds using a tween
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.5)

# ---- Draw road rectangles onto the map ----
func draw_roads():
	# Each road is [x, y, width, height]
	var road_rects = [
		[0,   330, 1280, 55],   # big horizontal road
		[610,   0,   55, 720],  # big vertical road
		[0,   150,  480, 44],
		[800, 150,  480, 44],
		[0,   530,  380, 44],
		[900, 530,  380, 44],
		[190,   0,   44, 310],
		[1046,  0,   44, 310],
		[190, 390,   44, 330],
		[1046,390,   44, 330],
	]

	for r in road_rects:
		# Make the grey road strip
		var road = ColorRect.new()
		road.offset_left   = r[0]
		road.offset_top    = r[1]
		road.offset_right  = r[0] + r[2]
		road.offset_bottom = r[1] + r[3]
		road.color = Color(0.22, 0.22, 0.22)
		$Roads.add_child(road)

		# Add a faint yellow centre line on horizontal roads
		if r[2] > r[3]:
			var line = ColorRect.new()
			line.offset_left   = r[0] + 20
			line.offset_top    = r[1] + r[3] * 0.44
			line.offset_right  = r[0] + r[2] - 20
			line.offset_bottom = r[1] + r[3] * 0.56
			line.color = Color(0.9, 0.8, 0.1, 0.35)
			$Roads.add_child(line)

# ---- Spawn house icons for every customer ----
func spawn_customers():
	for i in Global.customers.size():
		var customer = Global.customers[i]

		# A Node2D is just an invisible container we can position
		var house_node = Node2D.new()
		house_node.position = Vector2(customer.x, customer.y)

		# Blue backing square so the house is easy to see
		var bg = ColorRect.new()
		bg.offset_left   = -22
		bg.offset_top    = -22
		bg.offset_right  = 22
		bg.offset_bottom = 22
		bg.color = Color(0.2, 0.45, 0.85, 0.85)
		house_node.add_child(bg)

		# House emoji
		var icon = Label.new()
		icon.text = "🏠"
		icon.offset_left   = -18
		icon.offset_top    = -26
		icon.offset_right  = 18
		icon.offset_bottom = 2
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.add_theme_font_size_override("font_size", 28)
		house_node.add_child(icon)

		# Customer name underneath
		var name_label = Label.new()
		name_label.text = customer.name
		name_label.offset_left   = -40
		name_label.offset_top    = 22
		name_label.offset_right  = 40
		name_label.offset_bottom = 42
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 13)
		house_node.add_child(name_label)

		# Gentle pulsing glow animation
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(bg, "modulate:a", 0.4, 0.9)
		tween.tween_property(bg, "modulate:a", 1.0, 0.9)

		$CustomerLayer.add_child(house_node)
