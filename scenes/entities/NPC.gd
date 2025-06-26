extends CharacterBody2D
class_name NPC
## Basic NPC (Non-Player Character) for wedding game
## Handles dialogue, basic movement, and wedding guest interactions

signal dialogue_started(npc_name: String)
signal dialogue_ended(npc_name: String)
signal interaction_available(npc: NPC)
signal interaction_unavailable(npc: NPC)

@export var npc_name: String = "Guest"
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var can_move: bool = false
@export var movement_speed: float = 50.0
@export var interaction_distance: float = 64.0

# Node references
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D

# NPC state
var is_talking: bool = false
var player_nearby: bool = false
var facing_direction: int = 1
var movement_target: Vector2 = Vector2.ZERO
var idle_timer: float = 0.0

# Wedding-specific properties
@export var wedding_role: String = "guest"  # guest, family, staff, etc.
@export var mood: float = 1.0  # Affects dialogue and behavior
@export var has_wedding_ring: bool = false
@export var knows_secret: bool = false

func _ready() -> void:
	# Set up interaction area
	_setup_interaction_area()
	
	# Initialize NPC
	_setup_npc()
	
	# Connect to dialogue system if available
	if dialogue_resource:
		print("[NPC] %s ready with dialogue resource" % npc_name)
	else:
		print("[NPC] %s ready without dialogue resource" % npc_name)

func _setup_interaction_area() -> void:
	# Create interaction area for player detection
	interaction_area = Area2D.new()
	interaction_area.name = "InteractionArea"
	add_child(interaction_area)
	
	# Create collision shape for interaction
	var interaction_collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = interaction_distance
	interaction_collision.shape = circle_shape
	interaction_area.add_child(interaction_collision)
	
	# Set up collision layers
	interaction_area.collision_layer = 0
	interaction_area.collision_mask = 2  # Detect player layer
	
	# Connect area signals
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)

func _setup_npc() -> void:
	# Set up collision layers
	collision_layer = 16  # NPC layer
	collision_mask = 1  # World geometry
	
	# Set up default collision shape if not already configured
	if collision_shape and not collision_shape.shape:
		var capsule = CapsuleShape2D.new()
		capsule.height = 32.0
		capsule.radius = 8.0
		collision_shape.shape = capsule
	
	# Set up sprite if available
	if sprite:
		# Use placeholder sprite frames if none assigned
		if not sprite.sprite_frames:
			var frames = SpriteFrames.new()
			frames.add_animation("idle")
			frames.add_animation("walk")
			sprite.sprite_frames = frames
		
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	if is_talking:
		return
	
	if can_move and movement_target != Vector2.ZERO:
		_handle_movement(delta)
	else:
		_handle_idle(delta)

func _handle_movement(delta: float) -> void:
	var direction = (movement_target - global_position).normalized()
	
	if global_position.distance_to(movement_target) > 5.0:
		velocity = direction * movement_speed
		
		# Update facing direction
		if direction.x != 0:
			facing_direction = sign(direction.x)
			sprite.flip_h = facing_direction < 0
		
		# Play walk animation
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		movement_target = Vector2.ZERO
		velocity = Vector2.ZERO
		sprite.play("idle")
	
	move_and_slide()

func _handle_idle(delta: float) -> void:
	idle_timer += delta
	
	# Random idle movements for some NPCs
	if can_move and idle_timer > randf_range(3.0, 8.0):
		var random_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		set_movement_target(global_position + random_offset)
		idle_timer = 0.0

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body is Player:
		player_nearby = true
		interaction_available.emit(self)
		
		# Face the player
		var direction = global_position.direction_to(body.global_position)
		if direction.x != 0:
			facing_direction = sign(direction.x)
			sprite.flip_h = facing_direction < 0

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body is Player:
		player_nearby = false
		interaction_unavailable.emit(self)

## Start dialogue with this NPC
func start_dialogue() -> void:
	if is_talking or not player_nearby:
		return
	
	is_talking = true
	dialogue_started.emit(npc_name)
	
	# Integration with dialogue system (if available)
	if dialogue_resource and has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		if dialogue_manager.has_method("start_dialogue"):
			dialogue_manager.start_dialogue(dialogue_resource, dialogue_start)
	else:
		# Simple fallback dialogue
		_show_simple_dialogue()

func _show_simple_dialogue() -> void:
	# Basic dialogue fallback
	var dialogue_text = _get_default_dialogue()
	print("[NPC] %s: %s" % [npc_name, dialogue_text])
	
	# Simple dialogue UI (basic implementation)
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		if game_manager.has_method("show_dialogue"):
			game_manager.show_dialogue(npc_name, dialogue_text)
	
	# Auto-end dialogue after a moment
	await get_tree().create_timer(2.0).timeout
	end_dialogue()

func _get_default_dialogue() -> String:
	match wedding_role:
		"bride":
			return "I can't believe this is happening! Everything's going wrong!"
		"groom":
			return "We need to fix this mess before the ceremony!"
		"family":
			return "What a disaster! This wedding is falling apart!"
		"staff":
			return "I'm doing my best to keep everything together."
		"guest":
			if mood > 0.5:
				return "What an exciting wedding! So much happening!"
			else:
				return "This is quite chaotic... hope it gets better."
		_:
			return "Hello there! Lovely wedding, isn't it?"

## End dialogue with this NPC
func end_dialogue() -> void:
	if not is_talking:
		return
	
	is_talking = false
	dialogue_ended.emit(npc_name)

## Set movement target for NPC
func set_movement_target(target: Vector2) -> void:
	if can_move and not is_talking:
		movement_target = target

## Set NPC mood (affects dialogue and behavior)
func set_mood(new_mood: float) -> void:
	mood = clamp(new_mood, 0.0, 1.0)

## Wedding-specific interactions
func give_wedding_ring() -> bool:
	if has_wedding_ring:
		has_wedding_ring = false
		return true
	return false

func tell_secret() -> String:
	if knows_secret:
		return "I heard that the wedding cake is actually made of cardboard!"
	return ""

## Analytics integration
func _on_dialogue_started(npc_name_param: String) -> void:
	if AnalyticsManager:
		AnalyticsManager.track_dialogue_interaction(npc_name_param, dialogue_start)

func _on_dialogue_ended(npc_name_param: String) -> void:
	# Could track dialogue completion if needed
	pass

## Public API for other systems
func get_npc_info() -> Dictionary:
	return {
		"name": npc_name,
		"role": wedding_role,
		"mood": mood,
		"is_talking": is_talking,
		"has_ring": has_wedding_ring,
		"knows_secret": knows_secret,
		"position": global_position
	}

func can_interact() -> bool:
	return player_nearby and not is_talking