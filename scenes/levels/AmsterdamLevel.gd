extends Node2D
class_name AmsterdamLevel
## Amsterdam Tutorial Level - Where Mark proposes to Jenny
## Teaches basic movement and interaction

signal level_completed()

# Scene references
const GLEN_HOUSE_SCENE := "res://scenes/levels/GlenHouseLevel.tscn"

# Node references
@onready var player: Player = $Player
@onready var jenny_npc: NPC = $NPCs/JennyNPC
@onready var hud: HUD = $UI/HUD
@onready var tutorial_label: Label = $UI/TutorialLabel
@onready var canal_water: Area2D = $Environment/CanalWater
@onready var bridge: StaticBody2D = $Environment/Bridge
@onready var background_layer: ParallaxBackground = $ParallaxBackground
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Exploration elements
@onready var windmill: StaticBody2D = $Environment/ExplorationItems/Windmill
@onready var tulip_garden: StaticBody2D = $Environment/ExplorationItems/TulipGarden
@onready var canal_boat: StaticBody2D = $Environment/ExplorationItems/CanalBoat
@onready var bike_rack: StaticBody2D = $Environment/CulturalElements/BikeRack

# Environmental puzzles
@onready var lamp_switch: Area2D = $Environment/EnvironmentalPuzzles/LampPostPuzzle/LampSwitch
@onready var bridge_puzzle: Node2D = $Environment/EnvironmentalPuzzles/BridgePuzzle

# Level state
var tutorial_step: int = 0
var has_reached_jenny: bool = false
var proposal_started: bool = false

# Exploration state
var items_explored: Array[String] = []
var required_explorations: Array[String] = ["windmill", "tulips", "boat", "bike"]
var exploration_complete: bool = false

# Puzzle state
var lamps_lit: int = 0
var required_lamps: int = 2
var bridge_puzzle_solved: bool = false

# Tutorial texts
var tutorial_texts := [
	"Explore Amsterdam! Check out the windmill, tulips, canal boat, and bikes",
	"Light the lamp posts and solve the bridge puzzle to reach Jenny",
	"Press SPACE to propose!",
	"" # Empty for after proposal
]

func _ready() -> void:
	# Set up level
	GameManager.current_level = "AmsterdamLevel"
	
	# Configure player
	player.character_type = Player.CharacterType.MARK
	player.position = Vector2(200, 400)
	
	# Configure Jenny NPC
	jenny_npc.npc_name = "Jenny"
	jenny_npc.dialogue_lines = ["Mark! The view is beautiful here!"]
	jenny_npc.can_wander = false
	jenny_npc.position = Vector2(500, 400)
	
	# Set up environment
	_create_amsterdam_environment()
	
	# Show tutorial
	_show_tutorial_text(tutorial_texts[tutorial_step])
	
	# Play ambient music
	AudioManager.play_music("amsterdam_romantic")
	
	# Connect signals
	jenny_npc.interaction_area.body_entered.connect(_on_jenny_area_entered)
	
	# Connect exploration item signals
	_connect_exploration_signals()
	
	# Connect puzzle signals
	lamp_switch.body_entered.connect(_on_lamp_switch_activated)
	
	# Start intro animation
	if animation_player:
		animation_player.play("level_intro")

func _create_amsterdam_environment() -> void:
	# Create evening sky gradient with Dutch colors
	var sky_gradient = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.1, 0.09, 0.29))  # Dark blue
	gradient.add_point(0.5, Color(0.24, 0.22, 0.54)) # Purple
	gradient.add_point(1.0, Color(0.47, 0.52, 0.73)) # Light purple
	sky_gradient.gradient = gradient
	
	# Add stars for romantic atmosphere
	for i in range(50):
		_create_star()
	
	# Add lamp posts with Dutch styling
	_create_lamp_post(Vector2(150, 350))
	_create_lamp_post(Vector2(600, 350))
	
	# Add Amsterdam canal houses in background
	_create_background_houses()
	
	# Add Dutch canal water effects
	_create_canal_reflections()
	
	# Add windmill rotation animation
	_animate_windmill()
	
	# Add cultural sound effects
	_add_ambient_sounds()
	
	# Add romantic particles
	var heart_particles = CPUParticles2D.new()
	heart_particles.texture = preload("res://assets/sprites/effects/heart.png")
	heart_particles.amount = 5
	heart_particles.lifetime = 3.0
	heart_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
	heart_particles.emission_box_extents = Vector2(400, 10)
	heart_particles.position = Vector2(400, 200)
	heart_particles.direction = Vector2(0, -1)
	heart_particles.initial_velocity_min = 20.0
	heart_particles.initial_velocity_max = 50.0
	heart_particles.scale_amount_min = 0.5
	heart_particles.scale_amount_max = 1.0
	heart_particles.color = Color(1, 1, 1, 0.3)
	add_child(heart_particles)

func _create_star() -> void:
	var star = Sprite2D.new()
	star.texture = preload("res://assets/sprites/effects/star.png")
	star.position = Vector2(
		randf_range(0, 800),
		randf_range(0, 200)
	)
	star.scale = Vector2.ONE * randf_range(0.5, 1.0)
	star.modulate.a = randf_range(0.3, 0.8)
	add_child(star)
	
	# Twinkle animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(star, "modulate:a", randf_range(0.3, 1.0), randf_range(1.0, 3.0))
	tween.tween_property(star, "modulate:a", star.modulate.a, randf_range(1.0, 3.0))

func _create_lamp_post(pos: Vector2) -> void:
	# Post
	var post = ColorRect.new()
	post.size = Vector2(8, 40)
	post.position = pos
	post.color = Color(0.2, 0.2, 0.2)
	add_child(post)
	
	# Light
	var light = PointLight2D.new()
	light.texture = preload("res://assets/sprites/effects/light.png")
	light.position = pos + Vector2(4, -10)
	light.energy = 0.8
	light.color = Color(1.0, 0.9, 0.6)
	light.texture_scale = 2.0
	add_child(light)
	
	# Glow effect
	var glow = Sprite2D.new()
	glow.texture = preload("res://assets/sprites/effects/glow.png")
	glow.position = light.position
	glow.modulate = Color(1.0, 0.9, 0.6, 0.3)
	glow.scale = Vector2(2, 2)
	add_child(glow)
	
	# Animate glow
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(glow, "scale", Vector2(2.2, 2.2), 2.0)
	tween.tween_property(glow, "scale", Vector2(2.0, 2.0), 2.0)

func _create_background_houses() -> void:
	# This would typically be done with a tilemap or pre-made scenes
	var house_colors = [Color(0.55, 0.43, 0.34), Color(0.5, 0.4, 0.3), Color(0.43, 0.35, 0.28)]
	
	for i in range(5):
		var house_x = 100 + i * 140
		var house_height = randf_range(150, 200)
		
		# House body
		var house = ColorRect.new()
		house.size = Vector2(100, house_height)
		house.position = Vector2(house_x, 350 - house_height)
		house.color = house_colors[i % 3]
		house.z_index = -1
		add_child(house)
		
		# Windows
		for j in range(3):
			var window = ColorRect.new()
			window.size = Vector2(15, 20)
			window.position = house.position + Vector2(20 + j * 25, 20)
			window.color = Color(1.0, 0.9, 0.6, 0.8)
			add_child(window)

func _show_tutorial_text(text: String) -> void:
	tutorial_label.text = text
	tutorial_label.visible = true
	
	if text != "":
		# Pulse animation
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(tutorial_label, "modulate:a", 0.5, 1.0)
		tween.tween_property(tutorial_label, "modulate:a", 1.0, 1.0)

func _connect_exploration_signals() -> void:
	# Connect interaction areas for exploration items
	if windmill and windmill.get_node("InteractArea"):
		windmill.get_node("InteractArea").body_entered.connect(_on_windmill_explored)
	if tulip_garden and tulip_garden.get_node("InteractArea"):
		tulip_garden.get_node("InteractArea").body_entered.connect(_on_tulips_explored)
	if canal_boat and canal_boat.get_node("InteractArea"):
		canal_boat.get_node("InteractArea").body_entered.connect(_on_boat_explored)
	if bike_rack and bike_rack.get_node("InteractArea"):
		bike_rack.get_node("InteractArea").body_entered.connect(_on_bike_explored)

func _on_windmill_explored(body: Node2D) -> void:
	if body == player and not "windmill" in items_explored:
		items_explored.append("windmill")
		_show_exploration_message("You admire the traditional Dutch windmill. It's still turning!")
		_check_exploration_progress()

func _on_tulips_explored(body: Node2D) -> void:
	if body == player and not "tulips" in items_explored:
		items_explored.append("tulips")
		_show_exploration_message("Beautiful tulips! A classic symbol of the Netherlands.")
		_check_exploration_progress()

func _on_boat_explored(body: Node2D) -> void:
	if body == player and not "boat" in items_explored:
		items_explored.append("boat")
		_show_exploration_message("A charming canal boat floats peacefully in the water.")
		_check_exploration_progress()

func _on_bike_explored(body: Node2D) -> void:
	if body == player and not "bike" in items_explored:
		items_explored.append("bike")
		_show_exploration_message("Dutch bikes! The most popular way to get around Amsterdam.")
		_check_exploration_progress()

func _show_exploration_message(message: String) -> void:
	var exploration_label = Label.new()
	exploration_label.text = message
	exploration_label.add_theme_font_size_override("font_size", 16)
	exploration_label.add_theme_color_override("font_color", Color.YELLOW)
	exploration_label.position = Vector2(20, 50)
	add_child(exploration_label)
	
	# Fade out after 3 seconds
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(exploration_label, "modulate:a", 0.0, 1.0)
	tween.finished.connect(exploration_label.queue_free)

func _check_exploration_progress() -> void:
	if items_explored.size() >= required_explorations.size() and not exploration_complete:
		exploration_complete = true
		_show_exploration_message("Great exploring! Now solve the puzzles to reach Jenny.")
		tutorial_step = 1
		_show_tutorial_text(tutorial_texts[tutorial_step])

func _on_lamp_switch_activated(body: Node2D) -> void:
	if body == player:
		lamps_lit += 1
		_show_exploration_message("Lamp post lit! (%d/%d)" % [lamps_lit, required_lamps])
		_check_puzzle_progress()

func _check_puzzle_progress() -> void:
	if lamps_lit >= required_lamps and not bridge_puzzle_solved:
		bridge_puzzle_solved = true
		_activate_bridge()
		_show_exploration_message("Bridge activated! You can now reach Jenny.")

func _activate_bridge() -> void:
	# Make bridge sections solid for player to cross
	for i in range(3):
		var section = bridge_puzzle.get_node("BridgeSection%d" % (i + 1))
		if section:
			# Visual feedback - bridge sections become solid
			var tween = create_tween()
			tween.tween_property(section, "modulate:a", 1.0, 0.5)

func _on_jenny_area_entered(body: Node2D) -> void:
	if body == player and not has_reached_jenny:
		if not exploration_complete or not bridge_puzzle_solved:
			_show_exploration_message("Explore Amsterdam and solve the puzzles first!")
			return
			
		has_reached_jenny = true
		tutorial_step = 2
		_show_tutorial_text(tutorial_texts[tutorial_step])
		
		# Jenny speaks
		jenny_npc.speak("Mark! I'm so glad you're here!")

func _process(_delta: float) -> void:
	# Check for proposal input
	if has_reached_jenny and not proposal_started and Input.is_action_just_pressed("interact"):
		_start_proposal()

func _start_proposal() -> void:
	proposal_started = true
	tutorial_label.visible = false
	
	# Disable player input
	player.set_physics_process(false)
	
	# Mark kneels (animation)
	var tween = create_tween()
	tween.tween_property(player, "position:y", player.position.y + 20, 0.5)
	
	# Show ring
	var ring = Sprite2D.new()
	ring.texture = preload("res://assets/sprites/items/ring.png")
	ring.position = player.position + Vector2(0, -20)
	ring.scale = Vector2(2, 2)
	add_child(ring)
	
	# Dialogue sequence
	var dialogue_sequence = [
		{"speaker": "mark", "text": "Jenny, will you marry me?", "delay": 1.0},
		{"speaker": "jenny", "text": "Yes! Of course!", "delay": 3.0},
		{"speaker": "narrator", "text": "One Year Later...", "delay": 5.0}
	]
	
	for dialogue in dialogue_sequence:
		await get_tree().create_timer(dialogue.delay).timeout
		_show_dialogue(dialogue.speaker, dialogue.text)
	
	# Create lots of hearts
	await get_tree().create_timer(2.0).timeout
	for i in range(20):
		_create_celebration_heart()
		await get_tree().create_timer(0.1).timeout
	
	# Complete tutorial
	await get_tree().create_timer(3.0).timeout
	_complete_level()

func _show_dialogue(speaker: String, text: String) -> void:
	# This would use a proper dialogue system
	var dialogue_label = Label.new()
	dialogue_label.text = text
	dialogue_label.add_theme_font_size_override("font_size", 20)
	dialogue_label.add_theme_color_override("font_color", Color.WHITE)
	dialogue_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	
	match speaker:
		"narrator":
			dialogue_label.position = Vector2(400, 200)
			dialogue_label.add_theme_font_size_override("font_size", 32)
			dialogue_label.add_theme_font_override("font", preload("res://assets/fonts/italic_font.tres"))
		_:
			dialogue_label.position = Vector2(400, 300)
	
	dialogue_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(dialogue_label)
	
	# Fade in/out
	dialogue_label.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(dialogue_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(2.0)
	tween.tween_property(dialogue_label, "modulate:a", 0.0, 0.5)
	tween.finished.connect(dialogue_label.queue_free)

func _create_celebration_heart() -> void:
	var heart = Sprite2D.new()
	heart.texture = preload("res://assets/sprites/effects/heart.png")
	heart.position = Vector2(
		randf_range(200, 600),
		randf_range(300, 450)
	)
	heart.scale = Vector2.ONE * randf_range(0.5, 1.5)
	add_child(heart)
	
	# Float up and fade
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(heart, "position:y", heart.position.y - 100, 3.0)
	tween.tween_property(heart, "modulate:a", 0.0, 3.0)
	tween.finished.connect(heart.queue_free)

func _create_canal_reflections() -> void:
	# Add water reflection effects to enhance canal atmosphere
	var water_shimmer = CPUParticles2D.new()
	water_shimmer.amount = 10
	water_shimmer.lifetime = 2.0
	water_shimmer.position = Vector2(400, 520)
	water_shimmer.emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
	water_shimmer.emission_box_extents = Vector2(200, 5)
	water_shimmer.direction = Vector2(0, -1)
	water_shimmer.initial_velocity_min = 5.0
	water_shimmer.initial_velocity_max = 15.0
	water_shimmer.scale_amount_min = 0.3
	water_shimmer.scale_amount_max = 0.8
	water_shimmer.color = Color(0.6, 0.8, 1.0, 0.4)
	add_child(water_shimmer)

func _animate_windmill() -> void:
	# Animate windmill blades rotating
	if windmill and windmill.has_node("WindmillSprite"):
		var windmill_sprite = windmill.get_node("WindmillSprite")
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(windmill_sprite, "rotation", PI * 2, 8.0)

func _add_ambient_sounds() -> void:
	# Add subtle Dutch ambient sounds
	await get_tree().create_timer(2.0).timeout
	AudioManager.play_sound("canal_water", 0.3)
	await get_tree().create_timer(5.0).timeout
	AudioManager.play_sound("windmill_creak", 0.2)
	await get_tree().create_timer(7.0).timeout
	AudioManager.play_sound("bike_bell", 0.4)

func _complete_level() -> void:
	GameManager.flags["tutorial_complete"] = true
	GameManager.flags["amsterdam_explored"] = true
	level_completed.emit()
	
	# Fade to white then next scene
	var fade_rect = ColorRect.new()
	fade_rect.size = get_viewport_rect().size
	fade_rect.color = Color.WHITE
	fade_rect.modulate.a = 0.0
	fade_rect.z_index = 100
	add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	tween.finished.connect(func():
		SceneTransition.change_scene(GLEN_HOUSE_SCENE)
	)