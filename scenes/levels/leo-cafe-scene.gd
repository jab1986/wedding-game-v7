extends Node2D
class_name LeoCafeScene
## Leo's Cafe Scene - Safe haven and character switching tutorial
## Rest area between disasters with healing items

signal level_completed()
signal character_switch_learned()

# Scene references
const WEDDING_VENUE_SCENE := "res://scenes/levels/WeddingVenueLevel.tscn"

# Node references
@onready var player: Player = $Player
@onready var jack_npc: NPC = $NPCs/Jack
@onready var hipster_npcs: Node2D = $NPCs/Hipsters
@onready var hud: HUD = $UI/HUD
@onready var camera: Camera2D = $Camera2D
@onready var cafe_interior: Node2D = $CafeInterior
@onready var counter: StaticBody2D = $CafeInterior/Counter
@onready var food_display: Node2D = $CafeInterior/FoodDisplay
@onready var energy_station: Area2D = $CafeInterior/EnergyStation
@onready var exit_door: Area2D = $CafeInterior/ExitDoor
@onready var tutorial_popup: Control = $UI/TutorialPopup
@onready var ambient_audio: AudioStreamPlayer2D = $AmbientAudio

# Scene state
var has_talked_to_jack: bool = false
var has_restored_energy: bool = false
var switch_tutorial_shown: bool = false
var can_exit: bool = false
var hipster_dialogue_index: int = 0

# Social interaction system
var networking_score: int = 0
var conversations_had: Array[String] = []
var required_conversations: int = 3
var social_challenges_completed: Array[String] = []

# Coffee mini-game system
var coffee_orders_completed: int = 0
var current_coffee_order: Dictionary = {}
var coffee_ingredients := ["espresso", "milk", "foam", "syrup", "sprinkles"]
var coffee_recipes := {
	"latte": ["espresso", "milk", "foam"],
	"cappuccino": ["espresso", "milk", "foam", "sprinkles"], 
	"americano": ["espresso"],
	"mocha": ["espresso", "milk", "syrup"],
	"flat_white": ["espresso", "milk"]
}
var active_coffee_game: bool = false

# Enhanced dialogue system
var hipster_dialogues := [
	"This coffee is so artisanal...",
	"I was into weddings before they were cool.",
	"Have you tried the activated charcoal latte?",
	"The quinoa bowl here changed my life.",
	"I only drink single-origin, fair-trade coffee.",
	"Their oat milk is locally sourced.",
	"This playlist is so underground.",
	"I'm writing my novel here. It's about gentrification."
]

var conversation_topics := {
	"wedding_planning": [
		"Do you know any good sustainable wedding venues?",
		"I heard your friend's getting married! So mainstream.",
		"Wedding photography is my passion project."
	],
	"local_culture": [
		"This neighborhood has really changed since I moved here.",
		"The artisanal bakery down the street is amazing.",
		"Have you been to the underground poetry readings?"
	],
	"coffee_culture": [
		"The barista here really understands extraction ratios.",
		"I've been to the farm where these beans are grown.",
		"Pour-over is the only way to truly taste coffee."
	]
}

var character_development_topics := [
	{
		"name": "Maya",
		"profession": "Wedding Photographer", 
		"personality": "artistic_perfectionist",
		"dialogue": "I capture emotions, not just moments. Your wedding sounds like it has character!",
		"advice": "Make sure to have candid shots - those are the real memories.",
		"networking_value": 15
	},
	{
		"name": "Sage",
		"profession": "Event Coordinator",
		"personality": "detail_oriented", 
		"dialogue": "Organization is key to any successful event. Are you prepared for disasters?",
		"advice": "Always have a backup plan. And backup backup plans.",
		"networking_value": 20
	},
	{
		"name": "River",
		"profession": "Sustainable Florist",
		"personality": "eco_conscious",
		"dialogue": "Flowers should tell a story about your love for each other AND the planet.",
		"advice": "Local wildflowers are more meaningful than expensive imports.",
		"networking_value": 10
	}
]

func _ready() -> void:
	# Set up level
	GameManager.current_level = "LeoCafeScene"
	
	# Position player at entrance
	player.position = Vector2(100, 400)
	
	# Set up cafe environment
	_create_cafe_interior()
	
	# Configure NPCs
	_setup_npcs()
	
	# Set up interactions
	_setup_interactions()
	
	# Play cafe ambience
	AudioManager.play_music("cafe_ambient")
	_play_ambient_sounds()
	
	# Show objective
	hud.show_objective("Rest and prepare for the wedding venue")
	
	# Check if should show switch tutorial
	if GameManager.has_jenny and not GameManager.flags.get("switch_tutorial_shown", false):
		_show_switch_tutorial()

func _create_cafe_interior() -> void:
	# Create hipster cafe aesthetic
	var width = 800
	var height = 600
	
	# Wood floor
	var floor = ColorRect.new()
	floor.size = Vector2(width, 100)
	floor.position = Vector2(0, 500)
	floor.color = Color(0.54, 0.35, 0.17)
	cafe_interior.add_child(floor)
	
	# Exposed brick walls
	_create_brick_wall(Vector2(0, 0), Vector2(width, 500))
	
	# Counter setup
	counter.position = Vector2(400, 350)
	var counter_visual = ColorRect.new()
	counter_visual.size = Vector2(400, 60)
	counter_visual.position = Vector2(-200, -30)
	counter_visual.color = Color(0.29, 0.29, 0.29)
	counter.add_child(counter_visual)
	
	# Coffee machine
	var coffee_machine = Label.new()
	coffee_machine.text = "☕"
	coffee_machine.add_theme_font_size_override("font_size", 48)
	coffee_machine.position = Vector2(300, 320)
	cafe_interior.add_child(coffee_machine)
	
	# Menu board
	_create_menu_board()
	
	# Tables and seating
	_create_seating_areas()
	
	# Hipster decorations
	_add_hipster_decorations()

func _create_brick_wall(pos: Vector2, size: Vector2) -> void:
	var brick_wall = Node2D.new()
	brick_wall.position = pos
	cafe_interior.add_child(brick_wall)
	
	# Create brick pattern
	var brick_color = Color(0.7, 0.26, 0.13)
	var mortar_color = Color(0.5, 0.5, 0.5)
	
	for y in range(0, int(size.y), 20):
		for x in range(0, int(size.x), 40):
			var offset = 0 if (y / 20) % 2 == 0 else 20
			var brick = ColorRect.new()
			brick.size = Vector2(38, 18)
			brick.position = Vector2(x + offset, y)
			brick.color = brick_color
			brick_wall.add_child(brick)

func _create_menu_board() -> void:
	var menu_board = Panel.new()
	menu_board.size = Vector2(350, 180)
	menu_board.position = Vector2(225, 50)
	menu_board.color = Color(1.0, 1.0, 0.9) # Warm background
	cafe_interior.add_child(menu_board)
	
	# Leo Food logo/title with yellow accent
	var title = Label.new()
	title.text = "LEO FOOD 💛"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.1)) # Yellow accent
	title.position = Vector2(175, 15)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	menu_board.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Creative Community Kitchen"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	subtitle.position = Vector2(175, 35)
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	menu_board.add_child(subtitle)
	
	# Authentic Leo Food inspired menu items
	var menu_items = [
		"🍞 Basil Scrambles on Focaccia - £9",
		"🥑 Harissa Avocado Bowl - £8",
		"🍄 Seasonal Mushroom Plate - £10",
		"🌱 Creative Salad Special - £7",
		"☕ Single Origin Coffee - £3.50",
		"🥛 House-made Oat Milk Latte - £4"
	]
	
	for i in range(menu_items.size()):
		var item = Label.new()
		item.text = menu_items[i]
		item.add_theme_font_size_override("font_size", 13)
		item.position = Vector2(15, 55 + i * 18)
		menu_board.add_child(item)

func _create_seating_areas() -> void:
	var table_positions = [
		Vector2(150, 350),
		Vector2(650, 350),
		Vector2(150, 450),
		Vector2(650, 450)
	]
	
	for pos in table_positions:
		# Table (using ColorRect as fallback)
		var table_rect = ColorRect.new()
		table_rect.size = Vector2(60, 60)
		table_rect.position = pos - Vector2(30, 30)
		table_rect.color = Color(0.54, 0.35, 0.17)
		cafe_interior.add_child(table_rect)
		
		# Chairs
		for i in range(2):
			var chair_offset = Vector2(-30 + i * 60, 0)
			var chair = Label.new()
			chair.text = "🪑"
			chair.add_theme_font_size_override("font_size", 24)
			chair.position = pos + chair_offset
			cafe_interior.add_child(chair)

func _add_hipster_decorations() -> void:
	# Community bulletin board (Leo Food hosts events)
	_create_community_board()
	
	# Fixie bike on wall
	var bike = Label.new()
	bike.text = "🚲"
	bike.add_theme_font_size_override("font_size", 48)
	bike.position = Vector2(100, 100)
	bike.rotation = -0.1
	cafe_interior.add_child(bike)
	
	# Local art gallery wall
	var art_positions = [Vector2(600, 120), Vector2(650, 140), Vector2(700, 100)]
	for i in range(art_positions.size()):
		var artwork = ColorRect.new()
		artwork.size = Vector2(30, 40)
		artwork.position = art_positions[i]
		artwork.color = [Color(0.8, 0.6, 0.4), Color(0.6, 0.8, 0.5), Color(0.7, 0.5, 0.8)][i]
		cafe_interior.add_child(artwork)
	
	# Community plants (more lush than hipster plants)
	var plant_positions = [Vector2(50, 300), Vector2(750, 300), Vector2(400, 250), Vector2(120, 450)]
	for pos in plant_positions:
		var plant = Label.new()
		plant.text = ["🌿", "🌱", "🍃", "🌾"][randi() % 4]
		plant.add_theme_font_size_override("font_size", 28)
		plant.position = pos
		cafe_interior.add_child(plant)
	
	# Warm community lighting (Leo Food aesthetic)
	for i in range(4):
		var light_x = 150 + i * 150
		var light = PointLight2D.new()
		light.position = Vector2(light_x, 150)
		light.energy = 0.6
		light.texture_scale = 1.2
		light.color = Color(1.0, 0.9, 0.6) # Warmer yellow tone
		cafe_interior.add_child(light)
		
		# Bulb visual with yellow accent
		var bulb = Label.new()
		bulb.text = "💡"
		bulb.add_theme_font_size_override("font_size", 20)
		bulb.position = light.position
		bulb.modulate = Color(0.9, 0.7, 0.1) # Leo's yellow
		cafe_interior.add_child(bulb)

func _create_community_board() -> void:
	var board = Panel.new()
	board.size = Vector2(120, 80)
	board.position = Vector2(50, 200)
	board.color = Color(0.8, 0.6, 0.4)
	cafe_interior.add_child(board)
	
	var title = Label.new()
	title.text = "COMMUNITY 💛"
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color(0.9, 0.7, 0.1))
	title.position = Vector2(60, 5)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	board.add_child(title)
	
	var events = [
		"🎵 Live Music Tonight",
		"📖 Poetry Reading Wed",
		"☕ Coffee Cupping Sat"
	]
	
	for i in range(events.size()):
		var event = Label.new()
		event.text = events[i]
		event.add_theme_font_size_override("font_size", 8)
		event.position = Vector2(5, 20 + i * 15)
		board.add_child(event)

func _setup_npcs() -> void:
	# Configure Jack (Leo Food inspired)
	jack_npc.npc_name = "Jack"
	jack_npc.position = Vector2(400, 350)
	jack_npc.dialogue_lines = [
		"Welcome to Leo Food! This is our creative community kitchen!",
		"Everything here is made with love and sourced thoughtfully.",
		"We're all about bringing people together over good food.",
		"Try our basil scrambles - they're made fresh every morning!",
		"The wedding venue is just past the farm. Safe travels!"
	]
	jack_npc.can_wander = true
	jack_npc.wander_distance = 150
	jack_npc.wander_speed = 30
	
	# Create community customers
	_create_hipster_customers()

func _create_hipster_customers() -> void:
	# Create character development NPCs
	for i in range(character_development_topics.size()):
		var character_data = character_development_topics[i]
		var character = NPC.new()
		character.npc_name = character_data.name
		character.position = Vector2(150 + i * 250, 350 + (i % 2) * 100)
		character.dialogue_lines = [character_data.dialogue]
		character.can_wander = false
		character.use_random_dialogue = false
		character.interacted.connect(_on_character_interacted.bind(character_data))
		hipster_npcs.add_child(character)
		
		# Visual profession indicators
		var profession_emoji = _get_profession_emoji(character_data.profession)
		var indicator = Label.new()
		indicator.text = profession_emoji
		indicator.add_theme_font_size_override("font_size", 24)
		indicator.position = Vector2(15, -30)
		character.add_child(indicator)
		
		# Coffee cups
		var coffee = Label.new()
		coffee.text = "☕"
		coffee.position = Vector2(-10, -10)
		character.add_child(coffee)
	
	# Create additional atmospheric NPCs
	var atmospheric_positions = [
		Vector2(600, 380),
		Vector2(200, 480)
	]
	
	for i in range(atmospheric_positions.size()):
		var hipster = NPC.new()
		hipster.npc_name = "Local " + str(i + 1)
		hipster.position = atmospheric_positions[i]
		hipster.dialogue_lines = [hipster_dialogues[randi() % hipster_dialogues.size()]]
		hipster.can_wander = false
		hipster.use_random_dialogue = true
		hipster_npcs.add_child(hipster)
		
		var coffee = Label.new()
		coffee.text = "☕"
		coffee.position = Vector2(10, -10)
		hipster.add_child(coffee)

func _get_profession_emoji(profession: String) -> String:
	match profession:
		"Wedding Photographer":
			return "📸"
		"Event Coordinator":
			return "📋"
		"Sustainable Florist":
			return "🌸"
		_:
			return "💼"

func _on_character_interacted(character_data: Dictionary) -> void:
	var character_name = character_data.name
	
	if character_name in conversations_had:
		# Follow-up conversation
		_show_character_advice(character_data)
	else:
		# First conversation
		conversations_had.append(character_name)
		networking_score += character_data.networking_value
		_show_networking_dialogue(character_data)
		_update_networking_progress()

func _show_networking_dialogue(character_data: Dictionary) -> void:
	var dialogue_popup = _create_dialogue_popup()
	var character_name = character_data.name
	var profession = character_data.profession
	
	var title_text = "%s - %s" % [character_name, profession]
	var dialogue_text = character_data.dialogue
	
	_populate_dialogue_popup(dialogue_popup, title_text, dialogue_text, true)
	
	# Add networking score notification
	hud.show_notification("Networking +%d! (%d total)" % [character_data.networking_value, networking_score])

func _show_character_advice(character_data: Dictionary) -> void:
	var dialogue_popup = _create_dialogue_popup()
	var title_text = "%s's Advice" % character_data.name
	var advice_text = character_data.advice
	
	_populate_dialogue_popup(dialogue_popup, title_text, advice_text, false)

func _setup_interactions() -> void:
	# Jack interaction
	jack_npc.interacted.connect(_on_jack_interacted)
	
	# Energy station setup
	_create_energy_station()
	
	# Coffee ordering mini-game
	_setup_coffee_ordering_station()
	
	# Exit door
	exit_door.position = Vector2(750, 400)
	exit_door.body_entered.connect(_on_exit_door_entered)
	
	# Visual for exit
	var exit_sign = Label.new()
	exit_sign.text = "EXIT →"
	exit_sign.add_theme_font_size_override("font_size", 24)
	exit_sign.position = Vector2(700, 350)
	cafe_interior.add_child(exit_sign)

func _setup_coffee_ordering_station() -> void:
	var coffee_station = get_node("CafeInterior/CoffeeOrderingStation")
	coffee_station.body_entered.connect(_on_coffee_station_entered)
	
	# Visual coffee machine
	var machine = Label.new()
	machine.text = "☕🔧"
	machine.add_theme_font_size_override("font_size", 32)
	machine.position = Vector2(0, -20)
	coffee_station.add_child(machine)
	
	# Interaction prompt
	var prompt = Label.new()
	prompt.text = "Press E to make coffee!"
	prompt.add_theme_font_size_override("font_size", 12)
	prompt.position = Vector2(-30, 10)
	prompt.modulate = Color(1, 1, 0, 0.8)
	coffee_station.add_child(prompt)

func _on_coffee_station_entered(body: Node2D) -> void:
	if body == player and not active_coffee_game:
		if Input.is_action_just_pressed("interact"):
			_start_coffee_mini_game()

func _start_coffee_mini_game() -> void:
	active_coffee_game = true
	
	# Generate random order
	var drink_types = coffee_recipes.keys()
	var ordered_drink = drink_types[randi() % drink_types.size()]
	var required_ingredients = coffee_recipes[ordered_drink]
	
	current_coffee_order = {
		"drink": ordered_drink,
		"ingredients": required_ingredients,
		"player_ingredients": [],
		"timer": 15.0
	}
	
	_show_coffee_game_ui()

func _show_coffee_game_ui() -> void:
	var game_ui = Control.new()
	game_ui.name = "CoffeeGameUI"
	game_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(game_ui)
	
	# Background panel
	var panel = Panel.new()
	panel.size = Vector2(500, 350)
	panel.position = Vector2(150, 150)
	game_ui.add_child(panel)
	
	# Order display
	var order_label = Label.new()
	order_label.text = "Order: %s" % current_coffee_order.drink.capitalize()
	order_label.add_theme_font_size_override("font_size", 24)
	order_label.position = Vector2(200, 20)
	panel.add_child(order_label)
	
	# Required ingredients
	var ingredients_label = Label.new()
	var ingredients_text = "Ingredients needed: " + ", ".join(current_coffee_order.ingredients)
	ingredients_label.text = ingredients_text
	ingredients_label.add_theme_font_size_override("font_size", 16)
	ingredients_label.position = Vector2(20, 60)
	panel.add_child(ingredients_label)
	
	# Ingredient buttons
	for i in range(coffee_ingredients.size()):
		var ingredient = coffee_ingredients[i]
		var button = Button.new()
		button.text = ingredient.capitalize()
		button.size = Vector2(80, 40)
		button.position = Vector2(20 + (i % 3) * 90, 100 + (i / 3) * 50)
		button.pressed.connect(_on_ingredient_selected.bind(ingredient))
		panel.add_child(button)
	
	# Progress display
	var progress_label = Label.new()
	progress_label.name = "ProgressLabel"
	progress_label.text = "Added: "
	progress_label.position = Vector2(20, 220)
	panel.add_child(progress_label)
	
	# Timer display
	var timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.text = "Time: %.1f" % current_coffee_order.timer
	timer_label.position = Vector2(350, 220)
	panel.add_child(timer_label)
	
	# Submit button
	var submit_button = Button.new()
	submit_button.text = "Serve Coffee"
	submit_button.size = Vector2(120, 40)
	submit_button.position = Vector2(190, 270)
	submit_button.pressed.connect(_submit_coffee_order)
	panel.add_child(submit_button)
	
	# Cancel button
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.size = Vector2(80, 40)
	cancel_button.position = Vector2(350, 270)
	cancel_button.pressed.connect(_cancel_coffee_game)
	panel.add_child(cancel_button)

func _on_ingredient_selected(ingredient: String) -> void:
	if ingredient in current_coffee_order.player_ingredients:
		return # Already added
		
	current_coffee_order.player_ingredients.append(ingredient)
	_update_coffee_game_ui()

func _update_coffee_game_ui() -> void:
	var game_ui = get_node("CoffeeGameUI")
	if not game_ui:
		return
		
	var panel = game_ui.get_child(0)
	var progress_label = panel.get_node("ProgressLabel")
	var timer_label = panel.get_node("TimerLabel")
	
	progress_label.text = "Added: " + ", ".join(current_coffee_order.player_ingredients)
	timer_label.text = "Time: %.1f" % current_coffee_order.timer

func _submit_coffee_order() -> void:
	var required = current_coffee_order.ingredients
	var provided = current_coffee_order.player_ingredients
	
	# Check if ingredients match
	var correct = true
	if required.size() != provided.size():
		correct = false
	else:
		for ingredient in required:
			if not ingredient in provided:
				correct = false
				break
	
	if correct:
		_complete_coffee_order_success()
	else:
		_complete_coffee_order_failure()

func _complete_coffee_order_success() -> void:
	coffee_orders_completed += 1
	GameManager.happiness += 10
	GameManager.energy += 5
	
	hud.show_notification("Perfect coffee! +10 Happiness, +5 Energy")
	social_challenges_completed.append("barista_master")
	
	_end_coffee_game()

func _complete_coffee_order_failure() -> void:
	hud.show_notification("Not quite right... Try again!")
	_end_coffee_game()

func _cancel_coffee_game() -> void:
	_end_coffee_game()

func _end_coffee_game() -> void:
	active_coffee_game = false
	var game_ui = get_node("CoffeeGameUI")
	if game_ui:
		game_ui.queue_free()
	
	current_coffee_order.clear()

func _create_dialogue_popup() -> Control:
	var popup = Control.new()
	popup.name = "DialoguePopup"
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(popup)
	return popup

func _populate_dialogue_popup(popup: Control, title: String, text: String, show_networking: bool) -> void:
	var panel = Panel.new()
	panel.size = Vector2(400, 250)
	panel.position = Vector2(200, 200)
	popup.add_child(panel)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.position = Vector2(200, 20)
	title_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.add_child(title_label)
	
	var dialogue_label = Label.new()
	dialogue_label.text = text
	dialogue_label.add_theme_font_size_override("font_size", 14)
	dialogue_label.position = Vector2(20, 60)
	dialogue_label.size = Vector2(360, 120)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(dialogue_label)
	
	if show_networking:
		var networking_label = Label.new()
		networking_label.text = "Networking Score: %d" % networking_score
		networking_label.add_theme_font_size_override("font_size", 12)
		networking_label.position = Vector2(20, 180)
		panel.add_child(networking_label)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.size = Vector2(80, 30)
	close_button.position = Vector2(160, 200)
	close_button.pressed.connect(popup.queue_free)
	panel.add_child(close_button)

func _update_networking_progress() -> void:
	if conversations_had.size() >= required_conversations:
		social_challenges_completed.append("social_butterfly")
		hud.show_notification("Social Butterfly achievement unlocked!")
		GameManager.happiness += 20
	
	_check_exit_conditions()

func _create_energy_station() -> void:
	energy_station.position = Vector2(600, 300)
	
	# Visual
	var station_visual = Label.new()
	station_visual.text = "🧃"
	station_visual.add_theme_font_size_override("font_size", 48)
	energy_station.add_child(station_visual)
	
	# Glow effect (simplified without texture)
	var glow = PointLight2D.new()
	glow.energy = 0.5
	glow.color = Color(0.5, 1.0, 0.5)
	energy_station.add_child(glow)
	
	# Interaction
	energy_station.body_entered.connect(_on_energy_station_entered)

func _on_jack_interacted() -> void:
	has_talked_to_jack = true
	
	# Give vegan food
	if not GameManager.has_item("vegan_food"):
		GameManager.add_item("vegan_food")
		GameManager.energy = min(GameManager.MAX_ENERGY, GameManager.energy + 30)
		GameManager.happiness = min(GameManager.MAX_HAPPINESS, GameManager.happiness + 15)
		
		# Visual feedback
		var food = Label.new()
		food.text = "🥗"
		food.add_theme_font_size_override("font_size", 32)
		food.position = jack_npc.position
		add_child(food)
		
		var tween = create_tween()
		tween.tween_property(food, "position", player.position, 0.5)
		tween.tween_callback(func():
			food.queue_free()
			hud.show_notification("Received Vegan Food! +30 Energy")
		)
	
	_check_exit_conditions()

func _on_energy_station_entered(body: Node2D) -> void:
	if body != player or has_restored_energy:
		return
	
	has_restored_energy = true
	
	# Full restore
	GameManager.energy = GameManager.MAX_ENERGY
	GameManager.happiness = min(GameManager.MAX_HAPPINESS, GameManager.happiness + 20)
	
	hud.show_notification("Energy Restored! 🧃")
	
	# Visual effect
	var restore_effect = CPUParticles2D.new()
	restore_effect.position = player.position
	restore_effect.emitting = true
	restore_effect.amount = 30
	restore_effect.lifetime = 0.5
	restore_effect.initial_velocity_min = 50
	restore_effect.initial_velocity_max = 100
	restore_effect.color = Color(0.5, 1.0, 0.5)
	add_child(restore_effect)
	restore_effect.finished.connect(restore_effect.queue_free)
	
	# Disable station
	energy_station.get_child(0).modulate = Color(0.5, 0.5, 0.5)
	
	_check_exit_conditions()

func _check_exit_conditions() -> void:
	var social_complete = conversations_had.size() >= required_conversations
	var coffee_complete = coffee_orders_completed >= 1
	
	if has_talked_to_jack and has_restored_energy and social_complete:
		can_exit = true
		var bonus_msg = ""
		if coffee_complete:
			bonus_msg = " (Barista skills mastered!)"
		hud.show_notification("Ready to continue to the wedding venue!" + bonus_msg)
		
		# Save networking achievements
		GameManager.flags["cafe_networking_complete"] = true
		GameManager.flags["cafe_networking_score"] = networking_score
		if coffee_complete:
			GameManager.flags["cafe_barista_master"] = true

func _on_exit_door_entered(body: Node2D) -> void:
	if body == player and can_exit:
		level_completed.emit()
		SceneTransition.change_scene(WEDDING_VENUE_SCENE)
	elif body == player:
		hud.show_notification("Rest up before continuing!")

func _show_switch_tutorial() -> void:
	GameManager.flags["switch_tutorial_shown"] = true
	switch_tutorial_shown = true
	
	# Create tutorial popup
	tutorial_popup.visible = true
	
	var panel = Panel.new()
	panel.size = Vector2(400, 200)
	panel.position = Vector2(200, 200)
	tutorial_popup.add_child(panel)
	
	var title = Label.new()
	title.text = "Character Switching Unlocked!"
	title.add_theme_font_size_override("font_size", 24)
	title.position = Vector2(200, 20)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.add_child(title)
	
	var instructions = Label.new()
	instructions.text = "Press TAB to switch between Mark and Jenny!\n\nMark: Fast drumstick attacks\nJenny: Powerful camera bombs"
	instructions.add_theme_font_size_override("font_size", 16)
	instructions.position = Vector2(200, 100)
	instructions.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.add_child(instructions)
	
	var ok_button = Button.new()
	ok_button.text = "Got it!"
	ok_button.size = Vector2(100, 40)
	ok_button.position = Vector2(150, 150)
	panel.add_child(ok_button)
	
	ok_button.pressed.connect(func():
		tutorial_popup.visible = false
		character_switch_learned.emit()
	)

func _play_ambient_sounds() -> void:
	# Coffee machine sounds
	var coffee_timer = Timer.new()
	coffee_timer.wait_time = randf_range(5.0, 10.0)
	coffee_timer.timeout.connect(func():
		# Coffee steam sound (fallback to silent operation)
		# var steam_sound = AudioStreamPlayer2D.new()
		# steam_sound.stream = preload("res://assets/audio/sfx/coffee_steam.ogg")
		# if steam_sound.stream:
		#	steam_sound.position = Vector2(300, 320)
		#	steam_sound.volume_db = -10
		#	add_child(steam_sound)
		#	steam_sound.play()
		#	steam_sound.finished.connect(steam_sound.queue_free)
		
		# Steam visual
		var steam = Label.new()
		steam.text = "☁️"
		steam.position = Vector2(300, 300)
		add_child(steam)
		
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(steam, "position:y", steam.position.y - 30, 1.0)
		tween.tween_property(steam, "modulate:a", 0.0, 1.0)
		tween.chain().tween_callback(steam.queue_free)
		
		coffee_timer.wait_time = randf_range(5.0, 10.0)
		coffee_timer.start()
	)
	add_child(coffee_timer)
	coffee_timer.start()
	
	# Background chatter
	var chatter_timer = Timer.new()
	chatter_timer.wait_time = randf_range(8.0, 15.0)
	chatter_timer.timeout.connect(func():
		var chatter_pos = hipster_npcs.get_children()[randi() % hipster_npcs.get_child_count()].position
		var chatter = Label.new()
		chatter.text = ["💬", "🗣️", "💭"][randi() % 3]
		chatter.position = chatter_pos + Vector2(0, -30)
		chatter.modulate.a = 0.5
		add_child(chatter)
		
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(chatter, "position:y", chatter.position.y - 20, 2.0)
		tween.tween_property(chatter, "modulate:a", 0.0, 2.0)
		tween.chain().tween_callback(chatter.queue_free)
		
		chatter_timer.wait_time = randf_range(8.0, 15.0)
		chatter_timer.start()
	)
	add_child(chatter_timer)
	chatter_timer.start()

func _process(_delta: float) -> void:
	# Auto-restore small amount of energy while in cafe
	if Engine.get_physics_frames() % 120 == 0:  # Every 2 seconds
		if GameManager.energy < GameManager.MAX_ENERGY:
			GameManager.energy = min(GameManager.MAX_ENERGY, GameManager.energy + 1)

# Save system support
func get_save_data() -> Dictionary:
	return {
		"has_talked_to_jack": has_talked_to_jack,
		"has_restored_energy": has_restored_energy,
		"switch_tutorial_shown": switch_tutorial_shown,
		"can_exit": can_exit
	}

func load_save_data(data: Dictionary) -> void:
	has_talked_to_jack = data.get("has_talked_to_jack", false)
	has_restored_energy = data.get("has_restored_energy", false)
	switch_tutorial_shown = data.get("switch_tutorial_shown", false)
	can_exit = data.get("can_exit", false)