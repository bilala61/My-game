extends Node2D

# --------------------------------------------------
# SLICEGAME.GD
# This is the Fruit-Ninja-style mini-game.
#
# HOW IT WORKS:
#   - Sushi pieces fly up from the bottom of the screen.
#   - Click and drag to slice them before they fall back down.
#   - Slicing several at once gives you a COMBO bonus.
#   - Slicing DANGER items (💣🐡🌶) costs you a life.
#   - You have 30 seconds and 3 lives.
# --------------------------------------------------

# ----- CONSTANTS (these never change) -----
const TOTAL_TIME    = 30.0   # seconds the game lasts
const MAX_LIVES     = 3      # lives at the start
const GRAVITY       = 430.0  # how fast items fall back down
const ITEM_SIZE     = 36.0   # radius of each sushi circle

# ----- VARIABLES (these change as the game runs) -----
var time_left    = TOTAL_TIME
var lives        = MAX_LIVES
var slice_score  = 0
var combo        = 0           # current combo streak
var best_combo   = 0           # highest combo this game
var total_sliced = 0           # sushi successfully sliced
var game_over    = false

# Spawning - we spawn a new item every so often
var spawn_timer    = 0.0
var next_spawn_at  = 0.9       # seconds until the first item spawns

# Mouse / slicing
var mouse_is_down  = false
var mouse_last_pos = Vector2.ZERO
var trail_points   = []        # recent mouse positions for the white line

# All active items on screen are stored in this list.
# Each item is a dictionary, like a labelled box of properties.
var items = []

# ---- Called once when the scene loads ----
func _ready():
	# Show who we are delivering to
	if Global.current_order.size() > 0:
		$HUD/OrderInfoLabel.text = " Delivering for: " \
			+ Global.current_order.customer \
			+ "   Reward: $" + str(Global.current_order.reward)

	# Connect the "Keep Delivering" button
	$HUD/ResultBox/ContinueBtn.pressed.connect(go_back_to_map)

# ---- Called every frame ----
func _process(delta):
	# Stop doing anything if the game has ended
	if game_over:
		return

	# Count down the timer
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		end_game()
		return

	# Spawn new items on a timer
	spawn_timer += delta
	if spawn_timer >= next_spawn_at:
		spawn_timer = 0.0
		next_spawn_at = randf_range(0.5, 1.3)   # random delay until next item
		spawn_item()

	# Move every item that is on screen
	update_items(delta)

	# Update the HUD labels
	update_hud()

	# Fade out the white trail when the mouse is released
	if not mouse_is_down and trail_points.size() > 0:
		trail_points.clear()
		$SliceLine.points = PackedVector2Array()

# ---- Handle mouse input ----
func _input(event):
	if game_over:
		return

	# Mouse button pressed or released
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_is_down = event.pressed
		if event.pressed:
			# Start a fresh trail
			trail_points.clear()
			mouse_last_pos = event.position

	# Mouse moved while button is held = slicing motion
	if event is InputEventMouseMotion and mouse_is_down:
		var current_pos = event.position

		# Add this position to the visible trail
		trail_points.append(current_pos)
		if trail_points.size() > 18:
			trail_points.pop_front()           # keep only the last 18 points
		$SliceLine.points = PackedVector2Array(trail_points)

		# Check if this mouse movement sliced any items
		check_slice(mouse_last_pos, current_pos)
		mouse_last_pos = current_pos

# ---- Check if a mouse drag line sliced any items ----
func check_slice(from_pos, to_pos):
	var sliced_this_swipe = 0   # how many we slice in this single drag movement

	for item in items:
		# Skip items already sliced
		if item.sliced:
			continue

		# Check if the drag line passes through this item's circle
		var dist = distance_from_line(item.pos, from_pos, to_pos)
		if dist < ITEM_SIZE + 6:
			if item.is_danger:
				hit_danger(item)
			else:
				slice_sushi(item)
				sliced_this_swipe += 1

	# If we sliced more than one in a single swipe, that's a combo!
	if sliced_this_swipe > 1:
		combo += sliced_this_swipe
		if combo > best_combo:
			best_combo = combo
		show_combo_message(sliced_this_swipe)

# ---- Slice a sushi item ----
func slice_sushi(item):
	item.sliced = true
	total_sliced += 1
	combo += 1
	if combo > best_combo:
		best_combo = combo

	# Combo multiplier: each extra combo adds 50% more points
	var multiplier = 1.0 + (combo - 1) * 0.5
	var points_earned = int(item.data.points * multiplier)
	slice_score += points_earned

	# Show a floating +score popup at the item's position
	show_floating_text(item.pos, "+" + str(points_earned), Color(1, 0.95, 0.2))

	# Split the item visually into two halves
	split_item(item)

# ---- Hit a danger item (bad!) ----
func hit_danger(item):
	item.sliced = true
	lives -= 1
	combo = 0   # combo resets on a mistake

	var penalty = item.data.penalty
	slice_score = max(0, slice_score - penalty)

	show_floating_text(item.pos, "-" + str(penalty) + "!", Color(1, 0.2, 0.2))
	flash_red()

	# Remove it from screen
	item.node.queue_free()

	if lives <= 0:
		end_game()

# ---- Move all items each frame ----
func update_items(delta):
	var items_to_remove = []

	for i in items.size():
		var item = items[i]

		# Already sliced: animate the two halves flying apart
		if item.sliced:
			if item.has("half_left") and is_instance_valid(item.half_left):
				# Move each half
				item.vel_left  += Vector2(0, GRAVITY) * delta
				item.vel_right += Vector2(0, GRAVITY) * delta
				item.half_left.position  += item.vel_left  * delta
				item.half_right.position += item.vel_right * delta
				# Spin the halves
				item.half_left.rotation  += delta * item.spin
				item.half_right.rotation -= delta * item.spin
				# Fade them out
				item.half_left.modulate.a  -= delta * 1.8
				item.half_right.modulate.a -= delta * 1.8
				# Once fully transparent, remove
				if item.half_left.modulate.a <= 0:
					item.half_left.queue_free()
					item.half_right.queue_free()
					items_to_remove.append(i)
			continue

		# Not sliced yet: apply gravity and move upward arc
		item.vel += Vector2(0, GRAVITY) * delta
		item.pos += item.vel * delta
		item.node.position = item.pos
		item.node.rotation += delta * item.spin

		# If it fell off the bottom, it's gone
		if item.pos.y > 820:
			item.node.queue_free()
			items_to_remove.append(i)
			# Missed a sushi = lose a life (not for danger items though)
			if not item.is_danger:
				lives -= 1
				flash_screen(Color(1, 0.5, 0, 0.25))
				if lives <= 0:
					end_game()
					return

	# Remove items from the list (in reverse order so indexes stay correct)
	items_to_remove.reverse()
	for i in items_to_remove:
		items.remove_at(i)

# ---- Spawn a new item flying up from the bottom ----
func spawn_item():
	# 22% chance it's a danger item
	var is_danger = randf() < 0.22

	var data
	if is_danger:
		data = Global.danger_list[randi() % Global.danger_list.size()]
	else:
		data = Global.sushi_list[randi() % Global.sushi_list.size()]

	# Random starting X position
	var start_x = randf_range(100, 1180)
	var start_y = 760.0   # just below the screen

	# Random upward velocity with a slight sideways drift
	var vel_x = randf_range(-90, 90)
	var vel_y = randf_range(-700, -530)

	# Build the visual node
	var node = Node2D.new()

	# Coloured square as the sushi body
	var body = ColorRect.new()
	body.offset_left   = -ITEM_SIZE
	body.offset_top    = -ITEM_SIZE
	body.offset_right  = ITEM_SIZE
	body.offset_bottom = ITEM_SIZE
	body.color = data.color
	node.add_child(body)

	# Small shine highlight
	var shine = ColorRect.new()
	shine.offset_left   = -ITEM_SIZE * 0.5
	shine.offset_top    = -ITEM_SIZE * 0.75
	shine.offset_right  = 2
	shine.offset_bottom = -ITEM_SIZE * 0.1
	shine.color = Color(1, 1, 1, 0.28)
	node.add_child(shine)

	# Emoji label on top
	var emoji = Label.new()
	emoji.text = data.icon
	emoji.offset_left   = -ITEM_SIZE
	emoji.offset_top    = -ITEM_SIZE * 0.75
	emoji.offset_right  = ITEM_SIZE
	emoji.offset_bottom = ITEM_SIZE * 0.6
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", int(ITEM_SIZE))
	node.add_child(emoji)

	# Red ring around danger items so they are easy to spot
	if is_danger:
		var ring = ColorRect.new()
		ring.offset_left   = -ITEM_SIZE - 5
		ring.offset_top    = -ITEM_SIZE - 5
		ring.offset_right  = ITEM_SIZE + 5
		ring.offset_bottom = ITEM_SIZE + 5
		ring.color = Color(1, 0.1, 0.1, 0.45)
		node.add_child(ring)
		node.move_child(ring, 0)   # put the ring behind everything else

	node.position = Vector2(start_x, start_y)
	$ItemLayer.add_child(node)

	# Store all the item info in a dictionary
	var item = {
		"pos"      : Vector2(start_x, start_y),
		"vel"      : Vector2(vel_x, vel_y),
		"spin"     : randf_range(-3.0, 3.0),
		"is_danger": is_danger,
		"data"     : data,
		"sliced"   : false,
		"node"     : node,
	}
	items.append(item)

# ---- Split a sliced sushi into two halves that fly apart ----
func split_item(item):
	# Hide the original node
	item.node.visible = false

	# Left half
	var left = ColorRect.new()
	left.offset_left   = -ITEM_SIZE
	left.offset_top    = -ITEM_SIZE
	left.offset_right  = 0
	left.offset_bottom = ITEM_SIZE
	left.color = item.data.color
	left.position = item.pos
	add_child(left)

	# Right half (slightly darker)
	var right = ColorRect.new()
	right.offset_left   = 0
	right.offset_top    = -ITEM_SIZE
	right.offset_right  = ITEM_SIZE
	right.offset_bottom = ITEM_SIZE
	right.color = item.data.color * Color(0.8, 0.8, 0.8)
	right.position = item.pos
	add_child(right)

	# Give each half a velocity that flies it outward
	item.half_left  = left
	item.half_right = right
	item.vel_left   = item.vel + Vector2(-130, -70)
	item.vel_right  = item.vel + Vector2( 130, -70)

# ---- Show a big combo message on screen ----
func show_combo_message(count):
	var messages = ["DOUBLE! x2 🔥", "TRIPLE! x3 💥", "QUAD! x4 ⚡", "NINJA! x5 🌀", "MASTER! x6+ 👑"]
	var index = min(count - 2, messages.size() - 1)
	$HUD/ComboLabel.text = messages[index]
	$HUD/ComboLabel.modulate = Color(1, 0.85, 0.1, 1)
	var tween = create_tween()
	tween.tween_property($HUD/ComboLabel, "modulate:a", 0.0, 1.2)

# ---- Show a small number flying upward from a position ----
func show_floating_text(pos, text, colour):
	var label = Label.new()
	label.text = text
	label.position = pos
	label.modulate = colour
	label.add_theme_font_size_override("font_size", 30)
	$ItemLayer.add_child(label)
	# Animate it floating up and fading away
	var tween = create_tween()
	tween.tween_property(label, "position:y", pos.y - 90, 0.9)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tween.tween_callback(label.queue_free)

# ---- Flash the whole screen red (hit a danger item) ----
func flash_red():
	flash_screen(Color(1, 0, 0, 0.35))

func flash_screen(colour):
	var flash = ColorRect.new()
	flash.offset_right  = 1280
	flash.offset_bottom = 720
	flash.color = colour
	$HUD.add_child(flash)
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.4)
	tween.tween_callback(flash.queue_free)

# ---- Update all HUD labels ----
func update_hud():
	# Timer bar shrinks as time runs out
	$HUD/TimerBar.value = (time_left / TOTAL_TIME) * 100.0
	$HUD/TimeLabel.text = "⏱ " + str(int(time_left)) + "s"

	# Score
	$HUD/SliceScoreLabel.text = "Slice Score: " + str(slice_score)

	# Lives as heart emojis
	var hearts = ""
	for i in MAX_LIVES:
		if i < lives:
			hearts += "❤️"
		else:
			hearts += "🖤"
	$HUD/LivesLabel.text = hearts

# ---- End the game and show results ----
func end_game():
	if game_over:
		return
	game_over = true

	# Work out what the player earned
	var delivery_reward = Global.current_order.get("reward", 0)
	var combo_bonus     = best_combo * 5
	var total_earned    = slice_score + delivery_reward + combo_bonus

	# Add to the global totals
	Global.score      += total_earned
	Global.money      += delivery_reward + combo_bonus
	Global.deliveries += 1
	Global.current_order = {}   # clear the order

	# Build the results text
	var outcome = " DELIVERY COMPLETE! "
	if lives <= 0:
		outcome = " RAN OUT OF LIVES!"

	var results  = outcome + "\n\n"
	results     += "Sushi sliced:      " + str(total_sliced) + "\n"
	results     += "Best combo:        x" + str(best_combo) + "\n"
	results     += "Slice score:       " + str(slice_score) + "\n"
	results     += "Delivery reward:   $" + str(delivery_reward) + "\n"
	results     += "Combo bonus:       +" + str(combo_bonus) + " pts\n\n"
	results     += "  TOTAL EARNED:  " + str(total_earned) + " pts\n"
	results     += "Your total score:  " + str(Global.score)

	$HUD/ResultBox/ResultLabel.text = results
	$HUD/ResultBox.visible = true

# ---- Go back to the delivery map ----
func go_back_to_map():
	get_tree().change_scene_to_file("res://scenes/DeliveryMap.tscn")

# ---- Maths helper: distance from point P to line segment A→B ----
# This tells us whether the mouse drag passed through an item's circle.
func distance_from_line(point, line_start, line_end):
	var segment = line_end - line_start
	var to_point = point - line_start
	# How far along the segment is the closest spot?  (0 = at start, 1 = at end)
	var t = to_point.dot(segment) / max(segment.dot(segment), 0.001)
	t = clamp(t, 0.0, 1.0)
	# The actual closest point on the segment
	var closest = line_start + t * segment
	return point.distance_to(closest)
