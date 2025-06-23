extends Area2D
class_name ItemPickup
## Base class for collectible items
## Handles common pickup behavior and effects

signal collected(item_name: String, collector: Node2D)

# Item configuration
@export_group("Item Properties")
@export var item_name: String = "item"
@export var display_name: String = "Item"
@export var item_icon: Texture2D
@export var pickup_sound: AudioStream
@export var auto_collect: bool = true  # Collect on touch
@export var one_time_pickup: bool = true  # Can only be collected once

@export_group("Effects")
@export var float_enabled: bool = true
@export var float_amplitude: float = 5.0
@export var float_speed: float = 2.0
@export var rotate_enabled: bool = true
@export var rotation_speed: float = 1.0
@export var sparkle_enabled: bool = true
@export var sparkle_interval: float = 1.0

@export_group("Gameplay")
@export var health_restore: int = 0
@export var energy_restore: int = 0
@export var happiness_bonus: int = 0
@export var score_value: int = 100

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sparkle_timer: Timer = $SparkleTimer
@onready var interaction_prompt: Label = $InteractionPrompt

# State
var base_position: Vector2
var time_elapsed: float = 0.0
var is_collected: bool = false
var can_be_collected: bool = true

func _ready() -> void:
	# Store base position
	base_position = position
	
	# Set up collision
	collision_layer = 32  # Item layer
	collision_mask = 2    # Player layer
	
	# Set sprite texture if provided
	if item_icon and sprite:
		sprite.texture = item_icon
	
	# Connect signals
	if auto_collect:
		body_entered.connect(_on_body_entered)
	else:
		# Show interaction prompt when player is near
		body_entered.connect(_on_player_near)
		body_exited.connect(_on_player_far)
	
	# Set up sparkle timer
	if sparkle_enabled and sparkle_timer:
		sparkle_timer.wait_time = sparkle_interval
		sparkle_timer.timeout.connect(_create_sparkle)
		sparkle_timer.start()
	
	# Hide interaction prompt initially
	if interaction_prompt:
		interaction_prompt.visible = false
		interaction_prompt.text = "Press E to pick up"

func _physics_process(delta: float) -> void:
	if is_collected:
		return
	
	time_elapsed += delta
	
	# Floating animation
	if float_enabled:
		var float_offset = sin(time_elapsed * float_speed) * float_amplitude
		position.y = base_position.y + float_offset
	
	# Rotation
	if rotate_enabled and sprite:
		sprite.rotation += rotation_speed * delta

func _create_sparkle() -> void:
	if is_collected:
		return
	
	var sparkle = Sprite2D.new()
	sparkle.texture = preload("res://assets/sprites/effects/sparkle.png")
	sparkle.position = Vector2(
		randf_range(-20, 20),
		randf_range(-20, 20)
	)
	sparkle.scale = Vector2(0.5, 0.5)
	sparkle.modulate.a = 0.8
	add_child(sparkle)
	
	# If no texture, use emoji fallback
	if not sparkle.texture:
		sparkle.queue_free()
		var sparkle_label = Label.new()
		sparkle_label.text = "✨"
		sparkle_label.position = Vector2(
			randf_range(-20, 20),
			randf_range(-20, 20)
		)
		add_child(sparkle_label)
		sparkle = sparkle_label
	
	# Animate
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sparkle, "position:y", sparkle.position.y - 20, 0.5)
	tween.tween_property(sparkle, "modulate:a", 0.0, 0.5)
	tween.tween_property(sparkle, "scale", Vector2.ZERO, 0.5)
	tween.chain().tween_callback(sparkle.queue_free)

func _on_body_entered(body: Node2D) -> void:
	if auto_collect and body is Player and can_be_collected:
		collect(body)

func _on_player_near(body: Node2D) -> void:
	if body is Player and can_be_collected and interaction_prompt:
		interaction_prompt.visible = true

func _on_player_far(body: Node2D) -> void:
	if body is Player and interaction_prompt:
		interaction_prompt.visible = false

func _input(event: InputEvent) -> void:
	# Handle manual collection
	if not auto_collect and interaction_prompt and interaction_prompt.visible:
		if event.is_action_pressed("interact"):
			# Find player in area
			for body in get_overlapping_bodies():
				if body is Player:
					collect(body)
					break

func collect(collector: Node2D) -> void:
	if is_collected or not can_be_collected:
		return
	
	is_collected = true
	
	# Apply effects
	_apply_item_effects(collector)
	
	# Add to inventory
	if not item_name.is_empty():
		GameManager.add_item(item_name)
	
	# Play sound
	if pickup_sound:
		AudioManager.play_sfx_stream(pickup_sound)
	else:
		AudioManager.play_sfx("item_pickup")
	
	# Visual effect
	_play_collection_effect()
	
	# Emit signal
	collected.emit(item_name, collector)
	
	# Show notification
	_show_pickup_notification()
	
	# Handle persistence
	if one_time_pickup:
		queue_free()
	else:
		# Respawn after delay
		_respawn_after_delay(5.0)

func _apply_item_effects(collector: Node2D) -> void:
	# Restore health/energy
	if health_restore > 0:
		GameManager.happiness = min(GameManager.MAX_HAPPINESS, GameManager.happiness + health_restore)
	
	if energy_restore > 0:
		GameManager.energy = min(GameManager.MAX_ENERGY, GameManager.energy + energy_restore)
	
	if happiness_bonus > 0:
		GameManager.happiness = min(GameManager.MAX_HAPPINESS, GameManager.happiness + happiness_bonus)
	
	# Add score
	if score_value > 0 and has_method("add_score"):
		add_score(score_value)

func _play_collection_effect() -> void:
	# Hide sprite
	sprite.visible = false
	collision_shape.disabled = true
	set_physics_process(false)
	
	# Stop sparkles
	if sparkle_timer:
		sparkle_timer.stop()
	
	# Collection burst
	for i in range(8):
		var particle = Sprite2D.new()
		particle.texture = sprite.texture
		particle.scale = Vector2(0.5, 0.5)
		particle.position = Vector2.ZERO
		add_child(particle)
		
		var angle = (TAU / 8) * i
		var end_pos = Vector2(cos(angle), sin(angle)) * 50
		
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(particle, "position", end_pos, 0.5)
		tween.tween_property(particle, "scale", Vector2.ZERO, 0.5)
		tween.tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.chain().tween_callback(particle.queue_free)

func _show_pickup_notification() -> void:
	# Create floating text
	var notification = Label.new()
	notification.text = "+ %s" % display_name
	notification.add_theme_font_size_override("font_size", 18)
	notification.add_theme_color_override("font_color", Color.YELLOW)
	notification.position = Vector2(0, -30)
	add_child(notification)
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(notification, "position:y", notification.position.y - 30, 1.0)
	tween.tween_property(notification, "modulate:a", 0.0, 1.0)
	tween.chain().tween_callback(notification.queue_free)

func _respawn_after_delay(delay: float) -> void:
	can_be_collected = false
	
	await get_tree().create_timer(delay).timeout
	
	# Reset state
	is_collected = false
	can_be_collected = true
	sprite.visible = true
	collision_shape.disabled = false
	set_physics_process(true)
	
	if sparkle_timer and sparkle_enabled:
		sparkle_timer.start()
	
	# Respawn effect
	sprite.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC)

# Specific item implementations
class VeganFood extends ItemPickup:
	func _ready() -> void:
		item_name = "vegan_food"
		display_name = "Vegan Food"
		energy_restore = 50
		happiness_bonus = 10
		super._ready()

class EnergyDrink extends ItemPickup:
	func _ready() -> void:
		item_name = "energy_drink"
		display_name = "Energy Drink"
		energy_restore = 100
		float_amplitude = 10.0
		sparkle_interval = 0.5
		super._ready()

class HealthKit extends ItemPickup:
	func _ready() -> void:
		item_name = "health_kit"
		display_name = "Health Kit"
		health_restore = 50
		auto_collect = false  # Require interaction
		super._ready()