extends Node2D
class_name GlenHouseLevel
## Glen's House Level - Where all the disasters begin
## Features escalating chaos: aliens, fire, sewage

signal level_completed()
signal disaster_started(disaster_type: String)

# Scene references
const GLEN_BINGO_SCENE := "res://scenes/levels/GlenBingoLevel.tscn"
const LEO_CAFE_SCENE := "res://scenes/levels/LeoCafeLevel.tscn"
const ALIEN_SCENE := preload("res://scenes/entities/enemies/Alien.tscn")

# Node references
@onready var player: Player = $Player
@onready var glen: NPC = $NPCs/Glen
@onready var quinn: NPC = $NPCs/Quinn
@onready var hud: HUD = $UI/HUD
@onready var shed: Node2D = $Environment/Shed
@onready var house: Node2D = $Environment/House
@onready var garden: Node2D = $Environment/Garden
@onready var fence: StaticBody2D = $Environment/Fence
@onready var disaster_timer: Timer = $Timers/DisasterTimer
@onready var phase_label: Label = $UI/PhaseLabel
@onready var escape_prompt: Label = $UI/EscapePrompt
@onready var camera: Camera2D = $Camera2D

# Level state
var disaster_phase: int = 0
var aliens_spawned: bool = false
var fire_started: bool = false
var sewage_started: bool = false
var can_escape: bool = false
var aliens_group: Array[Node] = []
var fire_particles: Array[CPUParticles2D] = []

# Disaster phases
enum DisasterPhase {
	CALM,
	ALIENS,
	FIRE,
	SEWAGE,
	ESCAPE
}

# Chelsea score for Glen's mood
var chelsea_score := {"home": 2, "away": 1}
var glen_mood: float = 1.0  # Affects disaster intensity

func _ready() -> void:
	# Set up level
	GameManager.current_level = "GlenHouseLevel"
	
	# Set up player
	player.position = Vector2(100, 400)
	
	# Set up NPCs
	_setup_npcs()
	
	# Create environment
	_create_environment()
	
	# Connect signals
	disaster_timer.timeout.connect(_on_disaster_timer_timeout)
	
	# Start calm phase
	_set_disaster_phase(DisasterPhase.CALM)
	
	# Start disaster sequence after delay
	disaster_timer.start(3.0)
	
	# Play disaster music
	AudioManager.play_music("disaster_theme")
	
	# Show objective
	hud.show_objective("Survive the disasters and escape!")

func _setup_npcs() -> void:
	# Configure Glen
	glen.npc_name = "Glen"
	glen.dialogue_lines = [
		"Is this normal for weddings?",
		"Should I call Quinn?",
		"Are these your friends, Mark?",
		"The shed is... warm?",
		"I think the garden needs work..."
	]
	glen.can_wander = true
	glen.wander_distance = 100
	glen.position = Vector2(300, 400)
	
	# Quinn starts hidden (appears during fire)
	if quinn:
		quinn.visible = false
		quinn.npc_name = "Quinn"
		quinn.dialogue_lines = [
			"Glen! What did you do now?!",
			"I'll handle this... actually, you handle it.",
			"Where's the fire extinguisher?",
			"This is why we can't have nice things."
		]

func _create_environment() -> void:
	# Sky gradient
	var bg = ColorRect.new()
	bg.size = get_viewport_rect().size
	bg.color = Color(0.53, 0.81, 0.92)
	bg.z_index = -10
	add_child(bg)
	
	# Add grass texture
	for i in range(0, 800, 20):
		var grass = Label.new()
		grass.text = "🌱"
		grass.position = Vector2(i, 480)
		grass.rotation = randf_range(-0.2, 0.2)
		add_child(grass)
	
	# Create breakable fence sections
	if fence:
		for i in range(5):
			var fence_section = StaticBody2D.new()
			var collision = CollisionShape2D.new()
			var shape = RectangleShape2D.new()
			shape.size = Vector2(10, 40)
			collision.shape = shape
			fence_section.add_child(collision)
			
			var sprite = Sprite2D.new()
			sprite.texture = preload("res://assets/sprites/environment/fence_post.png")
			fence_section.add_child(sprite)
			
			fence_section.position = Vector2(700 + i * 20, 420)
			fence_section.add_to_group("breakable_fence")
			fence.add_child(fence_section)

func _set_disaster_phase(phase: DisasterPhase) -> void:
	disaster_phase = phase
	
	var phase_text := ""
	var phase_color := Color.WHITE
	
	match phase:
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
	
	# Animate phase label
	var tween = create_tween()
	tween.tween_property(phase_label, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(phase_label, "scale", Vector2(1.0, 1.0), 0.2)

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

func _start_alien_disaster() -> void:
	_set_disaster_phase(DisasterPhase.ALIENS)
	AudioManager.play_sfx("disaster_alarm")
	
	# Spawn aliens
	for i in range(3):
		var alien = ALIEN_SCENE.instantiate()
		alien.position = Vector2(700 + i * 50, 300)
		add_child(alien)
		aliens_group.append(alien)
		
		# Alien entrance animation
		alien.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(alien, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BOUNCE)
		tween.parallel().tween_property(alien, "position:y", 400, 1.0).set_trans(Tween.TRANS_BOUNCE)
	
	# Glen's reaction
	glen.speak("Are these your friends, Mark?")
	_update_glen_mood(-0.2)
	
	# Bad music effect
	var music_label = Label.new()
	music_label.text = "🎵 Bad Ghostbusters Theme 🎵"
	music_label.add_theme_font_size_override("font_size", 16)
	music_label.add_theme_color_override("font_color", Color.GREEN)
	music_label.position = Vector2(750, 250)
	add_child(music_label)
	
	# Animate music notes
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(music_label, "position:y", music_label.position.y - 10, 1.0)
	tween.tween_property(music_label, "position:y", music_label.position.y, 1.0)
	
	# Next disaster in 10 seconds
	disaster_timer.start(10.0)

func _start_fire_disaster() -> void:
	_set_disaster_phase(DisasterPhase.FIRE)
	AudioManager.play_sfx("disaster_alarm")
	GameManager.flags["shed_on_fire"] = true
	
	# Create fire on shed
	for i in range(5):
		var fire = CPUParticles2D.new()
		fire.texture = preload("res://assets/sprites/effects/fire_particle.png")
		fire.amount = 20
		fire.lifetime = 1.0
		fire.position = shed.position + Vector2(randf_range(-20, 20), randf_range(-10, 10))
		fire.direction = Vector2(0, -1)
		fire.initial_velocity_min = 50.0
		fire.initial_velocity_max = 100.0
		fire.scale_amount_min = 0.5
		fire.scale_amount_max = 1.5
		fire.color_ramp = preload("res://assets/sprites/effects/fire_gradient.tres")
		add_child(fire)
		fire_particles.append(fire)
		
		# Add fire emoji for visibility
		var fire_emoji = Label.new()
		fire_emoji.text = "🔥"
		fire_emoji.add_theme_font_size_override("font_size", 32)
		fire_emoji.position = fire.position
		add_child(fire_emoji)
		
		# Animate fire
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(fire_emoji, "position:y", fire_emoji.position.y - 10, 0.5)
		tween.tween_property(fire_emoji, "position:y", fire_emoji.position.y, 0.5)
	
	# Glen panics
	glen.speak("The shed is definitely warm now!")
	_update_glen_mood(-0.3)
	
	# Spawn Quinn
	_spawn_quinn()
	
	# Fire sound
	AudioManager.play_sfx("fire_crackle")
	
	# Next disaster in 8 seconds
	disaster_timer.start(8.0)

func _spawn_quinn() -> void:
	if not quinn:
		return
	
	quinn.visible = true
	quinn.position = Vector2(50, 400)
	quinn.speak("Glen! What did you do now?!")
	
	# Quinn entrance effect
	var tween = create_tween()
	tween.tween_property(quinn, "modulate:a", 1.0, 0.5).from(0.0)

func _start_sewage_disaster() -> void:
	_set_disaster_phase(DisasterPhase.SEWAGE)
	AudioManager.play_sfx("disaster_alarm")
	GameManager.flags["sewage_exploded"] = true
	
	# Create sewage effect
	for i in range(10):
		var sewage = Label.new()
		sewage.text = "💩"
		sewage.add_theme_font_size_override("font_size", 24)
		sewage.position = Vector2(randf_range(100, 700), 480)
		add_child(sewage)
		
		# Bubble up animation
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(sewage, "position:y", sewage.position.y - randf_range(20, 50), 1.0)
		tween.tween_property(sewage, "position:y", sewage.position.y, 1.0)
		tween.set_ease(Tween.EASE_IN_OUT)
	
	# Water splash sound
	AudioManager.play_sfx("water_splash")
	
	# Glen gives up
	glen.speak("Is this normal for weddings?")
	_update_glen_mood(-0.5)
	
	# Enable escape after 5 seconds
	disaster_timer.start(5.0)

func _enable_escape() -> void:
	_set_disaster_phase(DisasterPhase.ESCAPE)
	can_escape = true
	
	escape_prompt.text = "🏃 Escape to Leo's Cafe! Break through the fence! →"
	escape_prompt.visible = true
	
	# Flash escape prompt
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(escape_prompt, "modulate:a", 0.5, 0.5)
	tween.tween_property(escape_prompt, "modulate:a", 1.0, 0.5)
	
	# Make fence breakable
	for fence_post in get_tree().get_nodes_in_group("breakable_fence"):
		fence_post.set_collision_layer_value(1, false)
		fence_post.set_collision_layer_value(8, true)  # Trigger layer

func _update_glen_mood(change: float) -> void:
	glen_mood = clamp(glen_mood + change, 0.0, 1.0)
	
	# Check Chelsea score
	_check_chelsea_score()
	
	# Glen's mood affects disaster intensity
	if glen_mood < 0.3:
		# Maximum chaos
		Engine.time_scale = 1.2  # Speed up disasters
		glen.show_emote("😱")
	elif glen_mood < 0.6:
		# Moderate chaos
		glen.show_emote("😰")
	else:
		# Mild chaos
		glen.show_emote("😕")

func _check_chelsea_score() -> void:
	# Simulate checking phone
	if randf() < 0.3:  # 30% chance to check
		var home_goals = chelsea_score["home"]
		var away_goals = chelsea_score["away"]
		
		# Random score update
		if randf() < 0.5:
			chelsea_score["away"] += 1
			glen.speak("Oh no, Chelsea's down %d-%d!" % [home_goals, away_goals + 1])
			_update_glen_mood(-0.4)
		else:
			chelsea_score["home"] += 1
			glen.speak("Yes! Chelsea scored! %d-%d!" % [home_goals + 1, away_goals])
			_update_glen_mood(0.2)

func _physics_process(_delta: float) -> void:
	# Check for fence breaking
	if can_escape:
		for fence_post in get_tree().get_nodes_in_group("breakable_fence"):
			if player.global_position.distance_to(fence_post.global_position) < 50:
				if Input.is_action_pressed("attack") or abs(player.velocity.x) > 150:
					_break_fence(fence_post)

func _break_fence(fence_post: Node2D) -> void:
	# Create break effect
	for i in range(3):
		var piece = Sprite2D.new()
		piece.texture = preload("res://assets/sprites/effects/wood_piece.png")
		piece.position = fence_post.global_position + Vector2(randf_range(-20, 20), 0)
		add_child(piece)
		
		# Physics for pieces
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(piece, "position:x", piece.position.x + randf_range(-100, 100), 1.0)
		tween.tween_property(piece, "position:y", piece.position.y - randf_range(50, 150), 0.5).set_trans(Tween.TRANS_QUAD)
		tween.chain().tween_property(piece, "position:y", 500, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(piece, "rotation", randf_range(-PI, PI), 1.0)
		tween.chain().tween_callback(piece.queue_free)
	
	fence_post.queue_free()
	
	# Check if all fence broken
	if get_tree().get_nodes_in_group("breakable_fence").size() <= 1:
		_escape_to_cafe()

func _escape_to_cafe() -> void:
	AudioManager.play_sfx("wedding_bell_chime")
	hud.show_notification("You escaped the chaos! Time to regroup at Leo's Cafe!")
	level_completed.emit()
	
	# Transition after delay
	await get_tree().create_timer(2.0).timeout
	
	# Check if should go to Glen Bingo first
	if GameManager.glen_talked_count >= 3 and not GameManager.has_jenny:
		SceneTransition.change_scene(GLEN_BINGO_SCENE)
	else:
		SceneTransition.change_scene(LEO_CAFE_SCENE)

func _on_alien_defeated(alien: Node) -> void:
	aliens_group.erase(alien)
	GameManager.happiness += 5
	hud.show_notification("Alien defeated! +5 Happiness")
	
	# Glen comment
	if aliens_group.is_empty():
		glen.speak("Well, that was odd...")

# Handle player death
func _on_player_died() -> void:
	# Reload scene
	SceneTransition.reload_scene(SceneTransition.TransitionType.FADE_BLACK)