extends Node2D
class_name GlenHouseEnhanced
## Enhanced Glen's House Level with Tutorial Elements and Better Interactions

signal level_completed()
signal tutorial_completed()
signal disaster_started(disaster_type: String)

# Scene references - following Context7 best practices
const GLEN_BINGO_SCENE := "res://scenes/levels/glen_bingo.tscn"
const LEO_CAFE_SCENE := "res://scenes/levels/leo-cafe-scene.tscn"
const ALIEN_SCENE := preload("res://scenes/entities/enemies/Alien.tscn")

# Node references - using proper scene structure
@onready var player: Player = $Player
@onready var glen: NPC = $NPCs/Glen
@onready var quinn: NPC = $NPCs/Quinn
@onready var hud: HUD = $UI/HUD
@onready var camera: Camera2D = $Camera2D
@onready var tutorial_panel: Panel = $UI/TutorialPanel
@onready var tutorial_label: RichTextLabel = $UI/TutorialPanel/TutorialLabel
@onready var phase_label: Label = $UI/PhaseLabel
@onready var escape_prompt: Label = $UI/EscapePrompt
@onready var glen_indicator: Label = $InteractionIndicators/GlenIndicator

# Environment nodes
@onready var house: Node2D = $Environment/House
@onready var shed: Node2D = $Environment/Shed
@onready var garden: Node2D = $Environment/Garden
@onready var fence: StaticBody2D = $Environment/Fence

# Timers
@onready var disaster_timer: Timer = $Timers/DisasterTimer
@onready var tutorial_timer: Timer = $Timers/TutorialTimer

# Audio
@onready var disaster_audio: AudioStreamPlayer = $Audio/DisasterAudio
@onready var ambient_audio: AudioStreamPlayer = $Audio/AmbientAudio

# Enhanced tutorial system
var tutorial_active: bool = true
var tutorial_step: int = 0
var tutorial_steps: Array[Dictionary] = [
	{
		"title": "Welcome to Glen's House!",
		"description": "Use WASD or Arrow Keys to move around.",
		"trigger": "movement",
		"completed": false
	},
	{
		"title": "Talk to Glen",
		"description": "Walk near Glen and press E to interact.",
		"trigger": "glen_talk",
		"completed": false
	},
	{
		"title": "Prepare for Chaos",
		"description": "Disasters are coming! Watch the Phase indicator.",
		"trigger": "disaster_start",
		"completed": false
	},
	{
		"title": "Survive and Escape",
		"description": "Break through the fence when prompted to escape!",
		"trigger": "escape_ready",
		"completed": false
	}
]

# Enhanced level state
var disaster_phase: int = 0
var aliens_spawned: bool = false
var fire_started: bool = false
var sewage_started: bool = false
var can_escape: bool = false
var glen_talked_count: int = 0

# Collections for dynamic elements
var aliens_group: Array[Node] = []
var fire_particles: Array[CPUParticles2D] = []
var interactive_items: Array[Node] = []

# Disaster phases
enum DisasterPhase {
	TUTORIAL,
	CALM,
	ALIENS,
	FIRE,
	SEWAGE,
	ESCAPE
}

# Enhanced item interaction system
var interaction_range: float = 80.0
var current_interactable: Node = null

func _ready() -> void:
	# Initialize level
	_setup_level()
	_setup_tutorial()
	_setup_npcs()
	_create_environment()
	_setup_interactions()
	_connect_signals()
	
	# Start with tutorial
	_set_disaster_phase(DisasterPhase.TUTORIAL)

func _setup_level() -> void:
	GameManager.current_level = "GlenHouseLevel"
	
	# Position player at entrance
	player.position = Vector2(100, 400)
	
	# Setup camera to follow player
	camera.make_current()
	camera.follow_smoothing_enabled = true
	
	# Play ambient music
	AudioManager.play_music("disaster_theme")

func _setup_tutorial() -> void:
	# Show tutorial panel initially
	tutorial_panel.visible = true
	_update_tutorial_text()
	
	# Start tutorial timer
	tutorial_timer.start()
	tutorial_timer.timeout.connect(_on_tutorial_timer_timeout)

func _setup_npcs() -> void:
	# Enhanced Glen setup
	glen.npc_name = "Glen"
	glen.dialogue_lines = [
		"Mark! Good to see you. Ready for the wedding?",
		"Is this normal for weddings?",
		"Quinn will handle this...",
		"Are these your friends?",
		"The shed is... warm?",
		"I should probably watch the Chelsea game.",
		"Maybe we should call someone?"
	]
	glen.can_wander = true
	glen.wander_distance = 50
	glen.position = Vector2(300, 400)
	
	# Connect Glen interaction
	if glen.has_signal("dialogue_started"):
		glen.dialogue_started.connect(_on_glen_talked)
	
	# Quinn setup (hidden initially)
	quinn.visible = false
	quinn.npc_name = "Quinn"
	quinn.dialogue_lines = [
		"Glen! What have you done now?!",
		"I'll handle this... again.",
		"Someone needs to manage this house.",
		"Mark, help me with Glen!"
	]

func _create_environment() -> void:
	# Create enhanced visual environment
	_create_background()
	_create_interactive_objects()
	_setup_lighting()

func _create_background() -> void:
	# Enhanced sky gradient
	var bg = ColorRect.new()
	bg.size = Vector2(1200, 800)
	bg.color = Color(0.53, 0.81, 0.92)
	bg.z_index = -10
	add_child(bg)
	bg.move_to_front()
	
	# Add grass texture with better distribution
	for x in range(0, 1200, 30):
		for y in range(480, 520, 20):
			var grass = Label.new()
			grass.text = ["🌱", "🌿", "🍀"][randi() % 3]
			grass.position = Vector2(x + randf_range(-10, 10), y + randf_range(-5, 5))
			grass.rotation = randf_range(-0.3, 0.3)
			grass.modulate.a = randf_range(0.7, 1.0)
			add_child(grass)

func _create_interactive_objects() -> void:
	# Create interactable items around the house
	_create_shed_items()
	_create_garden_items()
	_create_house_items()

func _create_shed_items() -> void:
	# Fuel can near shed (fire hazard)
	var fuel_can = _create_interactive_item(
		Vector2(480, 380),
		"⛽",
		"Fuel Can",
		"Probably shouldn't leave this near the shed..."
	)
	fuel_can.add_to_group("fire_hazard")

func _create_garden_items() -> void:
	# Garden hose (fire extinguisher)
	var hose = _create_interactive_item(
		Vector2(350, 430),
		"🚿",
		"Garden Hose",
		"Might be useful for putting out fires!"
	)
	hose.add_to_group("fire_safety")
	
	# Fertilizer (sewage problem)
	var fertilizer = _create_interactive_item(
		Vector2(450, 470),
		"🧪",
		"Fertilizer",
		"This could make the sewage problem worse..."
	)
	fertilizer.add_to_group("sewage_hazard")

func _create_house_items() -> void:
	# Phone for calling help
	var phone = _create_interactive_item(
		Vector2(180, 320),
		"📞",
		"Phone",
		"Could call for help... if the lines weren't down."
	)
	phone.add_to_group("communication")

func _create_interactive_item(pos: Vector2, emoji: String, name: String, description: String) -> Node2D:
	var item = Node2D.new()
	item.position = pos
	item.name = name.replace(" ", "")
	
	# Visual representation
	var label = Label.new()
	label.text = emoji
	label.add_theme_font_size_override("font_size", 32)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.add_child(label)
	
	# Interaction area
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 30
	collision.shape = shape
	area.add_child(collision)
	item.add_child(area)
	
	# Store metadata
	item.set_meta("item_name", name)
	item.set_meta("description", description)
	item.set_meta("interactable", true)
	
	# Connect signals
	area.body_entered.connect(_on_item_area_entered.bind(item))
	area.body_exited.connect(_on_item_area_exited.bind(item))
	
	add_child(item)
	interactive_items.append(item)
	return item

func _setup_lighting() -> void:
	# Add ambient lighting effects
	var light = PointLight2D.new()
	light.texture = preload("res://assets/sprites/effects/light_gradient.png")
	light.energy = 0.3
	light.texture_scale = 3.0
	light.color = Color(1.0, 0.9, 0.7)
	light.position = Vector2(150, 200)  # House light
	house.add_child(light)

func _setup_interactions() -> void:
	# Enhanced fence system
	_create_breakable_fence()

func _create_breakable_fence() -> void:
	# Create fence sections with enhanced physics
	for i in range(6):
		var fence_section = StaticBody2D.new()
		fence_section.position = Vector2(700 + i * 30, 400)
		
		# Collision
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(15, 50)
		collision.shape = shape
		fence_section.add_child(collision)
		
		# Visual
		var sprite = Label.new()
		sprite.text = "🪵"
		sprite.add_theme_font_size_override("font_size", 40)
		sprite.rotation = randf_range(-0.1, 0.1)
		fence_section.add_child(sprite)
		
		# Add to group
		fence_section.add_to_group("breakable_fence")
		fence.add_child(fence_section)

func _connect_signals() -> void:
	# Connect timer signals
	disaster_timer.timeout.connect(_on_disaster_timer_timeout)
	
	# Connect player signals if available
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)

func _update_tutorial_text() -> void:
	if tutorial_step >= tutorial_steps.size():
		return
	
	var step = tutorial_steps[tutorial_step]
	var text = "[center][b]" + step.title + "[/b][/center]\n\n"
	text += step.description + "\n\n"
	text += "[color=gray]Step " + str(tutorial_step + 1) + " of " + str(tutorial_steps.size()) + "[/color]"
	
	tutorial_label.text = text

func _advance_tutorial() -> void:
	if tutorial_step < tutorial_steps.size() - 1:
		tutorial_steps[tutorial_step].completed = true
		tutorial_step += 1
		_update_tutorial_text()
	else:
		_complete_tutorial()

func _complete_tutorial() -> void:
	tutorial_active = false
	tutorial_panel.visible = false
	tutorial_completed.emit()
	
	# Start the actual game
	_set_disaster_phase(DisasterPhase.CALM)
	disaster_timer.start(3.0)

func _set_disaster_phase(phase: DisasterPhase) -> void:
	disaster_phase = phase
	
	var phase_text := ""
	var phase_color := Color.WHITE
	
	match phase:
		DisasterPhase.TUTORIAL:
			phase_text = "Tutorial Mode"
			phase_color = Color.CYAN
		DisasterPhase.CALM:
			phase_text = "Phase: Calm Before Storm"
			phase_color = Color.GREEN
		DisasterPhase.ALIENS:
			phase_text = "Phase: ALIEN INVASION!"
			phase_color = Color.PURPLE
			disaster_started.emit("aliens")
		DisasterPhase.FIRE:
			phase_text = "Phase: EVERYTHING'S ON FIRE!"
			phase_color = Color.ORANGE
			disaster_started.emit("fire")
		DisasterPhase.SEWAGE:
			phase_text = "Phase: SEWAGE EXPLOSION!"
			phase_color = Color.BROWN
			disaster_started.emit("sewage")
		DisasterPhase.ESCAPE:
			phase_text = "Phase: ESCAPE NOW!"
			phase_color = Color.YELLOW
	
	phase_label.text = phase_text
	phase_label.modulate = phase_color
	
	# Animated phase transition
	var tween = create_tween()
	tween.tween_property(phase_label, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(phase_label, "scale", Vector2(1.0, 1.0), 0.3)

# Enhanced input handling
func _process(_delta: float) -> void:
	_handle_tutorial_progress()
	_handle_item_interactions()
	_update_interaction_indicators()

func _handle_tutorial_progress() -> void:
	if not tutorial_active:
		return
	
	var current_step = tutorial_steps[tutorial_step]
	
	match current_step.trigger:
		"movement":
			if player.velocity.length() > 10:
				_advance_tutorial()
		"glen_talk":
			if glen_talked_count > 0:
				_advance_tutorial()
		"disaster_start":
			if disaster_phase >= DisasterPhase.ALIENS:
				_advance_tutorial()

func _handle_item_interactions() -> void:
	# Check for E key press on interactable items
	if Input.is_action_just_pressed("interact") and current_interactable:
		_interact_with_item(current_interactable)

func _interact_with_item(item: Node) -> void:
	var item_name = item.get_meta("item_name", "Unknown Item")
	var description = item.get_meta("description", "Nothing special.")
	
	AudioManager.play_sfx("menu_confirm_snes")
	
	# Show interaction feedback
	hud.show_notification("Interacted with " + item_name + ": " + description)
	
	# Item-specific effects
	if item.is_in_group("fire_safety") and fire_started:
		_extinguish_fires()
	elif item.is_in_group("communication"):
		glen.speak("The phone lines are down! We're on our own!")

func _extinguish_fires() -> void:
	# Put out some fires with the hose
	for fire in fire_particles:
		if fire and is_instance_valid(fire):
			var tween = create_tween()
			tween.tween_property(fire, "amount", 0, 2.0)
			tween.tween_callback(fire.queue_free)
	
	hud.show_notification("You put out some of the fires!")
	AudioManager.play_sfx("success_chime")
	AudioManager.play_sfx("water_splash")

func _update_interaction_indicators() -> void:
	# Update Glen indicator visibility
	var distance_to_glen = player.global_position.distance_to(glen.global_position)
	glen_indicator.visible = distance_to_glen < interaction_range

# Event handlers
func _on_tutorial_timer_timeout() -> void:
	if tutorial_active and tutorial_step == 0:
		_advance_tutorial()

func _on_glen_talked() -> void:
	glen_talked_count += 1
	GameManager.glen_talked_count = glen_talked_count
	
	# Tutorial progress
	if tutorial_active and tutorial_step == 1:
		_advance_tutorial()

func _on_item_area_entered(item: Node, body: Node) -> void:
	if body == player:
		current_interactable = item
		var item_name = item.get_meta("item_name", "Item")
		hud.show_interaction_prompt("Press E to interact with " + item_name)

func _on_item_area_exited(item: Node, body: Node) -> void:
	if body == player and current_interactable == item:
		current_interactable = null
		hud.hide_interaction_prompt()

func _on_disaster_timer_timeout() -> void:
	match disaster_phase:
		DisasterPhase.CALM:
			_start_alien_disaster()
		DisasterPhase.ALIENS:
			_start_fire_disaster()
		DisasterPhase.FIRE:
			_start_sewage_disaster()
		DisasterPhase.SEWAGE:
			_enable_escape()

func _on_player_health_changed(new_health: int) -> void:
	if new_health <= 0:
		_handle_player_death()

func _handle_player_death() -> void:
	hud.show_notification("The disasters were too much! Try again!")
	await get_tree().create_timer(2.0).timeout
	SceneTransition.reload_scene()

# Disaster implementations (simplified versions of the existing logic)
func _start_alien_disaster() -> void:
	_set_disaster_phase(DisasterPhase.ALIENS)
	AudioManager.play_sfx("disaster_alarm")
	glen.speak("Are these your friends, Mark?")
	disaster_timer.start(10.0)

func _start_fire_disaster() -> void:
	_set_disaster_phase(DisasterPhase.FIRE)
	fire_started = true
	AudioManager.play_sfx("disaster_alarm")
	glen.speak("The shed is definitely warm now!")
	_spawn_quinn()
	disaster_timer.start(8.0)

func _spawn_quinn() -> void:
	quinn.visible = true
	quinn.speak("Glen! What did you do now?!")

func _start_sewage_disaster() -> void:
	_set_disaster_phase(DisasterPhase.SEWAGE)
	AudioManager.play_sfx("disaster_alarm")
	glen.speak("Is this normal for weddings?")
	disaster_timer.start(5.0)

func _enable_escape() -> void:
	_set_disaster_phase(DisasterPhase.ESCAPE)
	can_escape = true
	escape_prompt.visible = true
	
	# Make fence breakable
	for fence_post in get_tree().get_nodes_in_group("breakable_fence"):
		fence_post.set_collision_layer_value(1, false)

func _physics_process(_delta: float) -> void:
	if can_escape:
		_check_fence_breaking()

func _check_fence_breaking() -> void:
	for fence_post in get_tree().get_nodes_in_group("breakable_fence"):
		var distance = player.global_position.distance_to(fence_post.global_position)
		if distance < 60 and (Input.is_action_pressed("attack") or abs(player.velocity.x) > 100):
			_break_fence(fence_post)

func _break_fence(fence_post: Node) -> void:
	fence_post.queue_free()
	AudioManager.play_sfx("wood_break")
	
	# Check if path is clear
	if get_tree().get_nodes_in_group("breakable_fence").size() <= 1:
		_escape_to_cafe()

func _escape_to_cafe() -> void:
	AudioManager.play_sfx("wedding_bell_chime")
	hud.show_notification("You escaped! Heading to Leo's Cafe...")
	level_completed.emit()
	
	await get_tree().create_timer(2.0).timeout
	
	# Check for bingo game
	if GameManager.glen_talked_count >= 3 and not GameManager.has_jenny:
		SceneTransition.change_scene(GLEN_BINGO_SCENE)
	else:
		SceneTransition.change_scene(LEO_CAFE_SCENE)