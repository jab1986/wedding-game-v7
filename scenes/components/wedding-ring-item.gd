extends Area2D
class_name WeddingRing
## Wedding Ring - The ultimate goal item
## Needed to complete the wedding ceremony

signal collected(collector: Node2D)

# Ring properties
@export var float_amplitude: float = 10.0
@export var float_speed: float = 2.0
@export var rotation_speed: float = 2.0
@export var sparkle_interval: float = 0.3
@export var collection_score: int = 1000

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var glow: PointLight2D = $Glow
@onready var sparkle_timer: Timer = $SparkleTimer
@onready var collection_particles: CPUParticles2D = $CollectionParticles
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# State
var base_position: Vector2
var time_elapsed: float = 0.0
var is_collected: bool = false

func _ready() -> void:
	# Store base position for floating animation
	base_position = position
	
	# Set up collision
	collision_layer = 32  # Item layer
	collision_mask = 2    # Player layer
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	sparkle_timer.timeout.connect(_create_sparkle)
	
	# Start sparkle timer
	sparkle_timer.wait_time = sparkle_interval
	sparkle_timer.start()
	
	# Set up glow
	if glow:
		glow.energy = 1.0
		glow.texture_scale = 2.0
		glow.color = Color(1.0, 0.843, 0.0, 0.8)  # Gold color
		
		# Animate glow
		var glow_tween = create_tween()
		glow_tween.set_loops()
		glow_tween.tween_property(glow, "energy", 1.5, 1.0)
		glow_tween.tween_property(glow, "energy", 1.0, 1.0)
	
	# Set up collection particles
	if collection_particles:
		collection_particles.emitting = false
		collection_particles.amount = 50
		collection_particles.lifetime = 1.0
		collection_particles.one_shot = true
		collection_particles.initial_velocity_min = 100
		collection_particles.initial_velocity_max = 300
		collection_particles.angular_velocity_min = -180
		collection_particles.angular_velocity_max = 180
		collection_particles.scale_amount_min = 0.5
		collection_particles.scale_amount_max = 1.5
		collection_particles.color = Color(1.0, 0.843, 0.0)

func _physics_process(delta: float) -> void:
	if is_collected:
		return
	
	time_elapsed += delta
	
	# Floating animation
	var float_offset = sin(time_elapsed * float_speed) * float_amplitude
	position.y = base_position.y + float_offset
	
	# Rotation
	sprite.rotation += rotation_speed * delta
	
	# Pulse scale
	var scale_factor = 1.0 + sin(time_elapsed * 3.0) * 0.1
	sprite.scale = Vector2(scale_factor, scale_factor)

func _create_sparkle() -> void:
	if is_collected:
		return
	
	# Create sparkle effect
	var sparkle = Label.new()
	sparkle.text = "✨"
	sparkle.add_theme_font_size_override("font_size", randf_range(16, 24))
	sparkle.position = position + Vector2(
		randf_range(-20, 20),
		randf_range(-20, 20)
	)
	sparkle.z_index = 1
	get_parent().add_child(sparkle)
	
	# Animate sparkle
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sparkle, "position:y", sparkle.position.y - 30, 1.0)
	tween.tween_property(sparkle, "modulate:a", 0.0, 1.0)
	tween.tween_property(sparkle, "scale", Vector2(0, 0), 1.0)
	tween.chain().tween_callback(sparkle.queue_free)

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	
	if body is Player:
		collect(body)

func collect(collector: Node2D) -> void:
	if is_collected:
		return
	
	is_collected = true
	
	# Stop animations
	set_physics_process(false)
	sparkle_timer.stop()
	
	# Add to inventory
	GameManager.add_item("ring")
	GameManager.has_ring = true
	
	# Play collection sound
	AudioManager.play_sfx("item_collect_special")
	
	# Visual collection effect
	_play_collection_effect()
	
	# Emit signal
	collected.emit(collector)
	
	# Important notification
	if collector.get_parent().has_method("show_notification"):
		collector.get_parent().hud.show_notification("💍 Wedding Ring Obtained! 💍")

func _play_collection_effect() -> void:
	# Hide sprite
	sprite.visible = false
	collision_shape.disabled = true
	
	# Start particles
	if collection_particles:
		collection_particles.emitting = true
	
	# Create expanding ring effect
	for i in range(3):
		var ring = create_tween()
		ring.set_parallel()
		
		var ring_sprite = Sprite2D.new()
		ring_sprite.texture = preload("res://assets/sprites/effects/ring_pulse.png")
		ring_sprite.modulate = Color(1.0, 0.843, 0.0, 0.8)
		ring_sprite.scale = Vector2(0.1, 0.1)
		add_child(ring_sprite)
		
		ring.tween_property(ring_sprite, "scale", Vector2(3, 3), 0.6 + i * 0.2)
		ring.tween_property(ring_sprite, "modulate:a", 0.0, 0.6 + i * 0.2)
		ring.chain().tween_callback(ring_sprite.queue_free)
		
		await get_tree().create_timer(0.1).timeout
	
	# Create spiral of hearts
	for i in range(8):
		var angle = (TAU / 8) * i
		var heart = Label.new()
		heart.text = "❤️"
		heart.position = Vector2.ZERO
		add_child(heart)
		
		var end_pos = Vector2(cos(angle), sin(angle)) * 100
		
		var heart_tween = create_tween()
		heart_tween.set_parallel()
		heart_tween.tween_property(heart, "position", end_pos, 1.0).set_trans(Tween.TRANS_QUAD)
		heart_tween.tween_property(heart, "rotation", angle + TAU, 1.0)
		heart_tween.tween_property(heart, "modulate:a", 0.0, 1.0)
		heart_tween.chain().tween_callback(heart.queue_free)
	
	# Screen flash
	var canvas_layer = CanvasLayer.new()
	get_tree().root.add_child(canvas_layer)
	
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.size = get_viewport().size
	canvas_layer.add_child(flash)
	
	var flash_tween = create_tween()
	flash_tween.tween_property(flash, "color:a", 0.5, 0.1)
	flash_tween.tween_property(flash, "color:a", 0.0, 0.3)
	flash_tween.tween_callback(canvas_layer.queue_free)
	
	# Destroy after effects complete
	await get_tree().create_timer(2.0).timeout
	queue_free()

# Make the ring more prominent
func highlight() -> void:
	var highlight_tween = create_tween()
	highlight_tween.set_loops(3)
	highlight_tween.tween_property(sprite, "modulate", Color(2, 2, 2), 0.3)
	highlight_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
	
	if glow:
		var glow_tween = create_tween()
		glow_tween.tween_property(glow, "energy", 3.0, 0.5)
		glow_tween.tween_property(glow, "energy", 1.0, 0.5)